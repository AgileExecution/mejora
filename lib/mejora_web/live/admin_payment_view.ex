defmodule MejoraWeb.Live.AdminPaymentView do
  use MejoraWeb, :live_view

  alias Mejora.Repo
  alias Mejora.Properties.Property
  alias Mejora.Transactions.PaymentNotice

  @months ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
  @default_case %{ paid: false, comment: "" }

  def mount(_params, _session, socket) do
    month_grid = PaymentNotice
              |> Repo.all()
              |> Enum.map(fn pnot -> {"#{pnot.property_id}_#{convert_date_to_month(pnot.due_date)}", %{paid: pnot.status == :paid, comment: pnot.comments}}  end)
              |> Map.new

    properties = Repo.all(Property)
                  |> Repo.preload(:payment_notices)
                  |> Enum.map(fn prop -> Map.put(prop, :payed_months, convert_payment_notice_to_payed_months(prop.payment_notices)) end)

    month_grid_v2 = Property
                    |> Repo.all()
                    |> Enum.map(fn prop -> Enum.map(@months, fn m -> "#{prop.id}_#{m}" end) end)
                    |> List.flatten()
                    |> Enum.map(fn mg2 -> { mg2, if Map.has_key?(month_grid, mg2) do Map.get(month_grid, mg2)  else @default_case end } end)
                    |> Map.new()

    # %{
    #   "1_Aug" => %{status: true, comment: "Mensualidad de dos meses"},
    #   "1_Jul" => %{status: true, comment: "Mensualidad faltante"},
    #   "1_Sep" => %{status: false, comment: "Mensualidad de dos meses"},
    #   "2_Oct" => %{status: false, comment: "Mensualidad faltante"}
    # }

    content = %{
      table_content: properties,
      months: @months,
      focused_on: nil,
      selected_input: @default_case,
      month_grid: month_grid_v2
    }

    {:ok, assign(socket, content)}
  end


  def handle_event("update_text", %{"comment-area" => value}, socket) do
    month_grid = socket.assigns.month_grid
    focused_on = socket.assigns.focused_on

    selected_value = Map.get(month_grid, focused_on)

    month_grid_v2 = month_grid |> Map.put(focused_on, Map.put(selected_value, :comment, value))

    # IO.puts "█ █ ▄▀█ █   █ █ █▀▀ \n▀▄▀ █▀█ █▄▄ █▄█ ██▄ focused-on: #{focused_on} ---- #{value}"

    {:noreply, assign(socket, :month_grid, month_grid_v2)}
  end


  def handle_event("selected-comment", %{"identifier" => identifier}, socket) do
    month_grid = socket.assigns.month_grid

    selected_value = month_grid |> Map.get(identifier)

    month_grid_v2 = month_grid |> Map.put(identifier, Map.put(selected_value, :paid, Kernel.not(selected_value.paid)))
    IO.inspect(selected_value)
    new_sock = socket
                  |> assign(:focused_on, identifier)
                  |> assign(:selected_input, selected_value)
                  |> assign(:month_grid, month_grid_v2)

    {:noreply, new_sock}
  end


  def handle_event("submit", _value, socket) do
    month_grid = socket.assigns.month_grid
    #                |> Enum.map(fn {k, v} ->
    #                   [property_id, month] = String.split(k, "_")

    #                   %{
    #                     property_id: property_id,
    #                     due_date: month,
    #                     comments: v.comment,
    #                     status: v.status
    #                   }
    #                 end)

    IO.inspect(month_grid)
    {:noreply, socket}
  end

  def convert_payment_notice_to_payed_months(payment_notice) do
    # Use a stream
    payment_notice
    |> Enum.filter(fn pay -> pay.status == :paid end)
    |> Enum.map(fn prop -> prop.due_date end)
    |> Enum.map(fn date -> convert_date_to_month(date) end)
  end

  def convert_date_to_month(due_date) do
    Enum.at(@months, due_date.month - 1)
  end
end
