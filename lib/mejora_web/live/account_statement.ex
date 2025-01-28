defmodule MejoraWeb.Live.AccountStatement do
  use MejoraWeb, :live_view
  alias Mejora.Repo
  alias Mejora.Neighborhoods.Quota
  alias Mejora.Transactions.Transaction

  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    neighborhood_id = 1
    quota = Repo.get_by(Quota, [neighborhood_id: neighborhood_id, status: "active"])

    transactions = Repo.all(Transaction)
    # IO.inspect(current_user)

    # ----------------------------------------------
    # ----------------------------------------------
    actual_budget = Decimal.new("420")
    anual_budget = quota.amount |> Decimal.mult(Decimal.new("12"))

    debt = Decimal.sub(anual_budget, actual_budget) |> Decimal.abs
    percentage = actual_budget |> Decimal.mult(Decimal.new("100")) |> Decimal.div_int(anual_budget) |> Decimal.to_float()
    # ----------------------------------------------
    # ----------------------------------------------

    radius = 150
    angle = :math.pi * percentage * 0.01
    x_cord = -radius * :math.cos(angle)
    y_cord = -radius * :math.sin(angle)

    # ----------------------------------------------
    # ----------------------------------------------

    angle_II = :math.pi * ( 1 + (percentage * 0.01))
    x_status = (170 + (160 * :math.cos(angle_II)))
    y_status = (145 + (133 * :math.sin(angle_II)))

    color = cond do
      percentage >= 82 -> "#7fe47e"
      percentage >= 69 -> "#ffeb3a"
      percentage >= 52 -> "#fcb5c3"
      true -> "#ff718b"
    end

    content = %{
      money: %{
        anual_budget: anual_budget,
        actual_budget: actual_budget,
        debt: debt,
        percentage: percentage
      },
      svg: %{
        progress: "<path d='M -150 0 A 150 150 0 0 1 #{x_cord} #{y_cord}' stroke='#1f9254' stroke-width='20' fill='none' />",
        checkpoint: " <circle cx='#{x_cord}' cy='#{y_cord}' r='15' fill='#1f9254' stroke='white' stroke-width='3'/>",
        status: " <circle cx='#{x_status}' cy='#{y_status}' r='15' fill='white' stroke='#{color}' stroke-width='8'/>"
      },
      transactions: transactions
    }

    {:ok, assign(socket, :content, content)}
  end

end
