defmodule MejoraWeb.Live.UserReceipt do
  use MejoraWeb, :live_view
  import Ecto.Query

  alias Mejora.Repo
  alias Mejora.Transactions.PaymentNotice

  def mount(params, _session, socket) do
    payment_id = params["id"] |> Integer.parse() |> elem(0)

    payment =
      PaymentNotice
      |> where(id: ^payment_id)
      |> Repo.one()

    payed = 0

    quota = %{
      id: payment.id,
      concept: "General",
      due_date: payment.due_date,
      incoming: payment.total,
      payed: payed,
      pending: to_num(payment.total) - payed,
      comments: payment.comments || "-"
    }

    {:ok, assign(socket, :quota, quota)}
  end

  def pending_sum(list) do
    list
    |> Enum.reduce(0, fn arr, acc -> arr.pending + acc end)
    |> Number.Currency.number_to_currency()
  end

  def to_num(value) do
    value |> Decimal.to_integer()
  end

  def currency(num) do
    Number.Currency.number_to_currency(num)
  end
end
