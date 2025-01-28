defmodule MejoraWeb.Live.Billing do
  alias Mejora.Repo
  alias Mejora.Accounts.User
  alias Mejora.Transactions

  use MejoraWeb, :salad_ui_live_view

  alias Mejora.RBAC

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if RBAC.has_permission?(current_user.role, "billing"),
      do: {:ok, assign_payment_notices(socket)},
      else:
        {:ok,
         socket
         |> redirect(to: "/")
         |> put_flash(:error, "You are not authorized to access this page.")}
  end

  defp assign_payment_notices(socket) do
    current_user = socket.assigns.current_user

    current_user =
      User
      |> Repo.get(current_user.id)
      |> Repo.preload(:properties)

    unpaid_payment_notices =
      Enum.reduce(current_user.properties, %{}, fn property, acc ->
        unpaid_payment_notices = Transactions.unpaid_payment_notices(property.id)
        Map.put(acc, property.id, unpaid_payment_notices)
      end)

    payment_notice = Map.values(unpaid_payment_notices) |> List.flatten() |> List.first()
    assign(socket, unpaid_payment_notices: unpaid_payment_notices, payment_notice: payment_notice)
  end

  defp pending_amount(payment_notices_map),
    do:
      payment_notices_map
      |> Map.values()
      |> List.flatten()
      |> Enum.reduce(0, fn payment_notice, sum ->
        Decimal.add(sum, payment_notice.total)
      end)
end
