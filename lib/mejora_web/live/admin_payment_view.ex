defmodule MejoraWeb.Live.AdminPaymentView do
  use MejoraWeb, :live_view

  alias Mejora.Repo
  alias Mejora.Properties.Property

  @months ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

  def mount(_params, _session, socket) do
    properties = Repo.all(Property)
              |> Repo.preload(:payment_notices)
              |> Enum.map(fn prop -> Map.put(prop, :payed_months, convert_payment_notice_to_payed_months(prop.payment_notices)) end)

    content = %{
      table: %{
        content: properties,
        months: @months,
      }
    }

    {:ok, assign(socket, :content, content)}
  end

  def convert_payment_notice_to_payed_months(payment_notice) do
    # Use a stream
    payment_notice
      |> Enum.filter(fn pay -> pay.status == :paid  end)
      |> Enum.map( fn prop -> prop.due_date end)
      |> Enum.map( fn date -> convert_date_to_month(date) end)
  end

  def convert_date_to_month(due_date) do
    Enum.at(@months, due_date.month - 1)
  end
end
