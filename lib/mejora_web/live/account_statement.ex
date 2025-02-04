defmodule MejoraWeb.Live.AccountStatement do
  use MejoraWeb, :live_view
  import Ecto.Query
  alias Mejora.Repo
  alias Mejora.Neighborhoods.Quota
  alias Mejora.Transactions.PaymentNotice

  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    neighborhood_id = 1
    transactions = get_payment_notice_from_user(current_user)

    anual_budget = Quota
                      |> Repo.get_by([neighborhood_id: neighborhood_id, status: "active"])
                      |> Map.get(:amount)
                      |> Decimal.mult(Decimal.new("12"))
                      |> Decimal.to_integer()

    actual_budget = transactions
                          |> Enum.map(fn(x) -> Decimal.to_integer(x.total) end)
                          |> Enum.sum()

    percentage = (actual_budget * 100) / anual_budget |> Kernel.round()

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
        debt: anual_budget - actual_budget,
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

  def get_payment_notice_from_user(current_user) do
    property_ids = current_user
                        |> Repo.preload(:properties)
                        |> Map.get(:properties)
                        |> Enum.map(&Map.get(&1, :id))

    Repo.all(
      from payments in PaymentNotice,
      where: payments.property_id in ^property_ids and payments.status == ^:paid
    )
  end
end
