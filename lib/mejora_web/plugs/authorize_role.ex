defmodule MejoraWeb.Plugs.AuthorizeRole do
  import Plug.Conn

  alias Phoenix.Controller

  def init(required_roles), do: required_roles

  def call(%{assigns: %{current_user: %{role: role}}} = conn, required_roles)
      when not is_nil(role) do
    if role in required_roles,
      do: conn,
      else:
        conn
        |> Controller.put_flash(:error, "You are not authorized to access this page.")
        |> Controller.redirect(to: "/")
        |> halt()
  end

  def call(conn, _required_roles),
    do:
      conn
      |> Controller.put_flash(:error, "You are not authorized to access this page.")
      |> Controller.redirect(to: "/")
      |> halt()
end
