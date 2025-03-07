defmodule MejoraWeb.Live.UserDebtsAndReceipts do
  use MejoraWeb, :live_view
  import Ecto.Query

  alias Mejora.Repo
  alias Mejora.Neighborhoods.Quota
  alias Mejora.Transactions.PaymentNotice

  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    quota = Quota |> Repo.get_by(status: :active)

    debts =
      current_user
      |> get_payment_notice_from_user()
      |> Enum.map(fn p ->
        # TODO: Find how to get payed!
        payed = 0
        incoming = p.total |> Decimal.to_integer()

        %{
          concept: "General",
          id: p.id,
          start_date: quota.start_date,
          end_date: p.due_date,
          incoming: incoming,
          payed: payed,
          pending: incoming - payed
        }
      end)

    payed = 0
    all_pending = debts |> Enum.reduce(0, fn arr, acc -> arr.pending + acc end)

    content = %{
      quota: %{
        start_date: quota.start_date,
        end_date: quota.end_date,
        incoming: quota.amount |> Decimal.to_integer(),
        payed: payed,
        pending: all_pending - payed
      },
      quotas: debts
    }

    {:ok, assign(socket, content)}
  end

  def pending_sum(list) do
    list
    |> Enum.reduce(0, fn arr, acc -> arr.pending + acc end)
    |> Number.Currency.number_to_currency()
  end

  def currency(num) do
    Number.Currency.number_to_currency(num)
  end

  def get_payment_notice_from_user(current_user) do
    property_ids =
      current_user
      |> Repo.preload(:properties)
      |> Map.get(:properties)
      |> Enum.map(&Map.get(&1, :id))

    Repo.all(
      from payments in PaymentNotice,
        where: payments.property_id in ^property_ids and payments.status == ^:unpaid
    )
  end
end
