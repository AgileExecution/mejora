defmodule MejoraWeb.Live.AccountStatement do
  use MejoraWeb, :live_view
  alias Mejora.Repo
  alias Mejora.Neighborhoods.Quota
  alias Mejora.Transactions.Transaction

  def mount(_params, _session, socket) do

    neighborhood_id = 1
    quota = Repo.get_by(Quota, [neighborhood_id: neighborhood_id, status: "active"])

    transactions = Repo.all(Transaction)

    # ----------------------------------------------
    # ----------------------------------------------
    actual_budget = Decimal.new("420")
    anual_budget = quota.amount |> Decimal.mult(Decimal.new("12"))

    debt = Decimal.sub(anual_budget, actual_budget) |> Decimal.abs
    percentage = actual_budget |> Decimal.mult(Decimal.new("100")) |> Decimal.div_int(anual_budget)

    # ----------------------------------------------
    # ----------------------------------------------

    content = %{
      money: %{
        anual_budget: anual_budget,
        actual_budget: actual_budget,
        debt: debt,
        percentage: percentage
      },
      svg: %{
        progress: "<path d='M -150 0 A 150 150 0 0 1 120 12' stroke='#1f9254' stroke-width='20' fill='none' />",
        checkpoint: " <circle cx='12' cy='120' r='15' fill='#1f9254' stroke='white' stroke-width='3'/>"
      },
      transactions: transactions
    }

    {:ok, assign(socket, :content, content)}
  end

end
