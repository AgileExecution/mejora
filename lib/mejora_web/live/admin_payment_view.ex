defmodule MejoraWeb.Live.AdminPaymentView do
  use MejoraWeb, :live_view

  alias Mejora.Repo
  alias Mejora.Properties.Property

  @months ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  def mount(_params, _session, socket) do
    properties = Repo.all(Property)
                  |> Repo.preload(:payment_notices)
                  |> Enum.map(fn prop -> Map.put(prop, :payed_months, convert_payment_notice_to_payed_months(prop.payment_notices)) end)

    content = %{
      table_content: properties,
      months: @months,
      current_comment: ""
    }

    {:ok, assign(socket, content)}
  end


  def handle_event("selected-comment", %{"month" => month, "record-id" => property_id}, socket) do
    properties = socket.assigns.table_content

    payment_notice = properties
                        |> Enum.find(fn prop -> Integer.to_string(prop.id) == property_id end)
                        |> Map.get(:payment_notices)
                        |> Enum.find(fn payments -> convert_date_to_month(payments.due_date) == month end)

    updated_properties = properties |> Enum.map(fn prop -> update_payment_notice(prop, month, property_id) end)
    selected_comment = payment_notice || %{ comments: "" }

    new_sock = socket
                  |> assign(:current_comment, selected_comment.comments)
                  |> assign(:table_content, updated_properties)

    {:noreply, new_sock}
  end

  def update_payment_notice(property, month, property_id) do
    payed_months = property.payed_months || []
    unmatched_property = Integer.to_string(property.id) != property_id
    month_fount_in_payed = Enum.member?(payed_months, month)

    case true do
      ^unmatched_property ->   property
      ^month_fount_in_payed ->  Map.put(property, :payed_months, List.delete(payed_months, month))
      _ ->   Map.put(property, :payed_months, [ month | payed_months ])
    end
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
