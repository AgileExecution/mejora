defmodule MejoraWeb.Live.UserDebtsAndReceipts do
  use MejoraWeb, :live_view

  def mount(_params, _session, socket) do
    content = %{
      quotas: [
        %{
          id: 38,
          concept: "General",
          date_start: "01-07-2025",
          date_end: "10-07-2025",
          incoming: 750,
          payed: 0,
          pending: 750
        }
      ]
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
end
