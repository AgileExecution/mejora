defmodule MejoraWeb.Live.AdminPaymentView do
  use MejoraWeb, :live_view
  import Ecto.Query

  alias Mejora.Repo
  alias Mejora.Properties.Property
  alias Mejora.Transactions.PaymentNotice

  @months ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
  @default_case %{ paid: false, comments: "" }

  def mount(_params, _session, socket) do
    month_grid = PaymentNotice
              |> Repo.all()
              |> Enum.map(fn pnot -> {"#{pnot.property_id}_#{convert_date_to_month(pnot.due_date)}", %{paid: pnot.status == :paid, comments: pnot.comments, id: pnot.id}}  end)
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
    month_grid_v2 = month_grid |> Map.put(focused_on, Map.put(selected_value, :comments, value))

    {:noreply, assign(socket, :month_grid, month_grid_v2)}
  end


  def handle_event("selected-input", %{"identifier" => identifier}, socket) do
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
    divide_month_grid(month_grid)

    IO.inspect(month_grid)
    {:noreply, socket}
  end

  def divide_month_grid(month_grid) do
    update_these = month_grid
                      |> Enum.filter(fn x -> x |> elem(1) |> Map.has_key?(:id) end)
                      |> Enum.map(fn record ->
                        element = record |> elem(1)
                        id = element |> Map.get(:id)
                        attr = %{
                          comments: Map.get(element, :comments),
                          status: if Map.get(element, :paid) do :paid else :unpaid end
                        }

                        PaymentNotice |> Repo.get(id) |> Ecto.Changeset.change(attr) |> Repo.update()
                      end)

    save_these = month_grid
                    |> Enum.filter(fn x -> x |> elem(1) |> Map.has_key?(:id) |> Kernel.not() end)
                    |> parse_month_grid()
                    |> Enum.map(fn m ->
                      PaymentNotice.embedded_changeset(m) |> Repo.insert!()
                    end)

    %{ update: update_these, save: save_these }
  end

  def parse_month_grid(month_grid) do
    month_grid
        |> Enum.map(fn {k, v} ->
            [property_id, month] = String.split(k, "_")

            p_month = Enum.find_index(@months, fn m -> m == month end) + 1
            [ street, prop_number ] = retrieve_property(property_id)

            date = {2024, p_month, 11}
            paid = if v.paid do :paid else :unpaid end
            comments = v.comments
            index = 0
            quota = "500.00"

            {
              [ street, prop_number, date, comments, quota, :sale, paid ],
              index
            }
          end)
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

  def retrieve_property(property_id) do
    { id, _ } = Integer.parse(property_id)
    found = Property |> where(id: ^id) |> Repo.all() |> List.first()

    [found.street, found.number]
  end
end
