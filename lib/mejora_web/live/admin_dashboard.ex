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
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("upload", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :spreadsheet_file, fn %{path: path}, _entry ->
        {:ok, read_spreadsheet(path)}
      end)

    {:noreply, assign(socket, :data, uploaded_files)}
  end

  defp read_spreadsheet(file_path) do
    case Xlsxir.multi_extract(file_path) do
      [
        {:ok, neighborhoods},
        {:ok, boards},
        {:ok, properties},
        {:ok, people},
        {:ok, providers},
        {:ok, income_transactions},
        {:ok, outcome_transactions}
        | _
      ] ->
        Task.Supervisor.async(Mejora.TaskSupervisor, fn ->
          Task.async(fn ->
            Importers.Boards.process(boards) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.Neighborhoods.process(neighborhoods) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.Properties.process(properties) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.People.process(people) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.Providers.process(providers) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.Transactions.process(income_transactions) |> IO.inspect()
          end)

          Task.async(fn ->
            Importers.Transactions.process(outcome_transactions) |> IO.inspect()
          end)
        end)

      {:error, reason} ->
        IO.inspect(reason)
    end
  end
end
