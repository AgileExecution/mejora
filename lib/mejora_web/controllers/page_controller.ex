defmodule MejoraWeb.PageController do
  use MejoraWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def show(conn, _params) do
    payment_dates = ["11-11-2024", "10-10-2024", "12-09-2024", "13-08-2024", "12-06-2024", "10-05-2024", "10-04-2024"]
    anual_budget = 205800
    actual_budget = 188650

    debt = anual_budget - actual_budget
    radius = 150
    percentage = actual_budget/anual_budget

    # -------------------------------------------------

    x_cord = ((radius*2*percentage) - 150)
    y_cord = -(((radius**2) - (x_cord**2))**0.5)

    svg_progress = "<path d='M -150 0 A 150 150 0 0 1 #{x_cord} #{y_cord}' stroke='#1f9254' stroke-width='20' fill='none' />"
    circle_progress = " <circle cx='#{x_cord}' cy='#{y_cord}' r='15' fill='#1f9254' stroke='white' stroke-width='3'/>"

    money = %{
      anual_budget: Number.Currency.number_to_currency(anual_budget, precision: 0),
      actual_budget: Number.Currency.number_to_currency(actual_budget, precision: 0),
      debt: Number.Currency.number_to_currency(debt, precision: 0),
      percentage: Float.to_string(percentage*100, decimals: 0)
    }

    render(conn, :show, payment_dates: payment_dates, money: money, svg_progress: svg_progress, circle_progress: circle_progress, layout: false)
  end
end
