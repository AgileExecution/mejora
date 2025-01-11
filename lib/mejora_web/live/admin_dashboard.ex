defmodule MejoraWeb.Live.AdminDashboard do
  use MejoraWeb, :salad_ui_live_view

  alias Mejora.Importers
  alias Mejora.RBAC

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if RBAC.has_permission?(current_user.role, "view_stats"),
      do:
        {:ok,
         socket
         |> assign(:data, nil)
         |> allow_upload(:spreadsheet_file,
           accept: ~w(.xlsx),
           max_entries: 1,
           max_file_size: 100 * 1024 * 1024
         )},
      else:
        {:ok,
         socket
         |> redirect(to: "/")
         |> put_flash(:error, "You are not authorized to access this page.")}
  end

  @impl true
  def handle_info({_reg, _transactions}, socket) do
    {:noreply, socket}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _error}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload", _params, socket) do
    content =
      socket
      |> consume_uploaded_entries(:spreadsheet_file, fn %{path: path}, _entry ->
        {:ok, extract_data(path)}
      end)
      |> async_import_stream()

    {:noreply, assign(socket, :data, content)}
  end

  defp parse_field(_field, value), do: value

  defp get_worksheet_name(0), do: :neighborhoods
  defp get_worksheet_name(1), do: :boards
  defp get_worksheet_name(2), do: :properties
  defp get_worksheet_name(3), do: :people_old
  defp get_worksheet_name(4), do: :people
  defp get_worksheet_name(5), do: :providers
  defp get_worksheet_name(6), do: :income_transactions
  defp get_worksheet_name(7), do: :outcome_transactions
  defp get_worksheet_name(8), do: :quotas
  defp get_worksheet_name(_), do: :unknown

  defp extract_data(path) do
    path
    |> Xlsxir.multi_extract()
    |> Enum.with_index()
    |> Enum.map(fn {{:ok, worksheet_id}, index} ->
      worksheet_id
      |> Xlsxir.get_mda()
      |> Enum.reduce({nil, []}, fn {subindex, row}, {keys, results} ->
        if subindex == 0 do
          {row, results}
        else
          result =
            Map.new(row, fn {key, value} ->
              {keys[key], parse_field(keys[key], value)}
            end)

          {keys, [result | results]}
        end
      end)
      |> then(fn {_, data} ->
        {get_worksheet_name(index), data}
      end)
    end)
  end

  defp async_import_stream([content]) do
    Task.Supervisor.async_nolink(Mejora.TaskSupervisor, fn ->
      content
      |> Enum.map(fn {worksheet_name, data} ->
        {worksheet_name,
         data
         |> Enum.reverse()
         |> Enum.with_index(2)}
      end)
      |> Importers.import_stream!()
    end)

    content
  end
end
