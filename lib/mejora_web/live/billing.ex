defmodule MejoraWeb.Live.Billing do
  alias Mejora.Repo
  alias Mejora.Accounts.User
  alias Mejora.Transactions

  use MejoraWeb, :salad_ui_live_view

  alias Mejora.RBAC

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if RBAC.has_permission?(current_user.role, "billing"),
      do: {:ok, assign_invoices(socket)},
      else:
        {:ok,
         socket
         |> redirect(to: "/")
         |> put_flash(:error, "You are not authorized to access this page.")}
  end

  defp assign_invoices(socket) do
    current_user = socket.assigns.current_user

    current_user =
      User
      |> Repo.get(current_user.id)
      |> Repo.preload(:properties)

    unpaid_invoices =
      Enum.reduce(current_user.properties, %{}, fn property, acc ->
        unpaid_invoices = Transactions.unpaid_invoices(property.id)
        Map.put(acc, property.id, unpaid_invoices)
      end)

    invoice = Map.values(unpaid_invoices) |> List.flatten() |> List.first()
    assign(socket, unpaid_invoices: unpaid_invoices, invoice: invoice)
  end

  defp pending_amount(invoices_map),
    do:
      invoices_map
      |> Map.values()
      |> List.flatten()
      |> Enum.reduce(0, fn invoice, sum ->
        Decimal.add(sum, invoice.total)
      end)
end
