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
        {:ok, Importers.process_spreadsheet(path, truncate: true)}
      end)

    {:noreply, assign(socket, :data, uploaded_files)}
  end
end
