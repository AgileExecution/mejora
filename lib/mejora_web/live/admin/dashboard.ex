defmodule MejoraWeb.Live.AdminDashboard do
  use MejoraWeb, :salad_ui_live_view

  alias Mejora.Importer
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
    results =
      socket
      |> consume_uploaded_entries(:spreadsheet_file, fn %{path: path}, _entry ->
        {:ok, Importer.extract_data(path)}
      end)
      |> Importer.import_stream(truncate: false)

    case results do
      {:error, spreadsheet_errors} ->
        IO.inspect(spreadsheet_errors)
        {:noreply, assign(socket, :data, spreadsheet_errors)}

      {:ok, records} ->
        IO.inspect(records)
        {:noreply, assign(socket, :data, :done)}
    end
  end

  defp global(assigns) do
    ~H"""
    <div>{@data}</div>
    """
  end

  def rows(assigns) do
    ~H"""
    <%= for {row, message} <- @data do %>
      <.alert variant="destructive" class="mb-2">
        <.icon name="hero-exclamation-triangle" class="h-4 w-4" />
        <.alert_title>Row: {row}</.alert_title>
        <.alert_description>
          <.message data={message} />
        </.alert_description>
      </.alert>
    <% end %>
    """
  end

  defp message(assigns) do
    ~H"""
    <ul class="ml-2">
      <%= for item <- String.split(@data, ";") do %>
        <li>
          {item}
        </li>
      <% end %>
    </ul>
    """
  end

  defp errors(%{data: %Mejora.Importer.SpreadsheetErrors{} = data} = assigns) do
    ~H"""
    <div>
      <.global data={data.global} />
      <.rows data={data.rows} />
    </div>
    """
  end

  defp errors(%{data: nil} = assigns) do
    ~H"""
    <div></div>
    """
  end

  defp errors(%{data: :done} = assigns) do
    ~H"""
    <div>Done!</div>
    """
  end
end
