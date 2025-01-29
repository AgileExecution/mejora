defmodule MejoraWeb.Live.AdminPaymentView do
  use MejoraWeb, :live_view

  def mount(_params, _session, socket) do
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

    table_content = [
      %{
        street: "15 de Mayo",
        number: "790",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Colima",
        number: "300",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Cuernavaca",
        number: "307",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Colima",
        number: "301",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "15 de Mayo",
        number: "792",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun",  "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Cuernavaca",
        number: "308",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Cuernavaca",
        number: "309",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May",  "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Colima",
        number: "302",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "15 de Mayo",
        number: "794",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Colima",
        number: "303",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Cuernavaca",
        number: "90",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Colima",
        number: "304",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "!5 de Mayo",
        number: "795",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "Cuernavaca",
        number: "796",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "15 de Mayo",
        number: "789",
        payed_months: ["Jan", "Feb", "Mar", "Apr", "May", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "15 de Mayo",
        number: "788",
        payed_months: ["Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
      %{
        street: "15 de Mayo",
        number: "787",
        payed_months: ["Jan", "Feb", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct" ]
      },
    ]


    content = %{
      table: %{
        content: table_content,
        months: months,
      }
    }

    {:ok, assign(socket, :content, content)}
  end

end
