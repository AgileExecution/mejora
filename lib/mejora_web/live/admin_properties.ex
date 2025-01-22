defmodule MejoraWeb.Live.AdminProperties do
  use MejoraWeb, :live_view

  alias Mejora.Neighborhoods
  alias Mejora.Properties

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    current_user = Mejora.Repo.preload(current_user, [:property_memberships, :properties])
    property = current_user.properties |> Enum.at(0)

    properties =
      property.neighborhood_id
      |> Neighborhoods.get_properties()
      |> Enum.map(&assign_status_class(&1))

    property_count = Neighborhoods.current_property_count(property.neighborhood_id)
    monthly_quota = Neighborhoods.current_quota(property.neighborhood_id)
    neighborhood_quota = Neighborhoods.expected_monthly_quota(property.neighborhood_id)

    {:ok,
     socket
     |> assign(:properties, properties)
     |> assign(:monthly_quota, monthly_quota)
     |> assign(:property_count, property_count)
     |> assign(:neighborhood_quota, neighborhood_quota)}
  end

  def mount(_params, _session, socket),
    do:
      {:ok,
       socket
       |> redirect(to: "/login")
       |> put_flash(:error, "Inicia sesión para continuar.")}

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    property = Properties.get_property!(id)
    new_status = if property.status == :active, do: :inactive, else: :active
    Properties.update_property(property, %{status: new_status})

    current_user =
      Mejora.Repo.preload(socket.assigns.current_user, [:property_memberships, :properties])

    property = current_user.properties |> Enum.at(0)

    updated_properties =
      Properties.get_properties(neighborhood_id: property.neighborhood_id)
      |> Enum.map(&assign_status_class(&1))

    {:noreply, assign(socket, :properties, updated_properties)}
  end

  defp assign_status_class(property) do
    # Date.utc_today()
    current_date = ~D[2023-05-14]
    current_month = current_date.month
    current_day = current_date.day

    months_passed =
      if current_day >= 15 do
        current_month
      else
        current_month - 1
      end

    months_passed = max(months_passed, 0)
    cuota_actual = months_passed * 350

    pagado =
      case Float.parse("100.00") do
        {value, _} -> value
        :error -> 0.0
      end

    status_class =
      cond do
        pagado == cuota_actual -> "current"
        pagado < cuota_actual -> "late"
        pagado > cuota_actual -> "advance"
      end

    payment_status =
      case status_class do
        "current" -> "Al corriente"
        "late" -> "Atrasado"
        "advance" -> "Adelanto"
        _ -> "unknown"
      end

    property
    |> Map.put(:status_class, status_class)
    |> Map.put(:payment_status, payment_status)
    |> Map.put(:months_passed, months_passed)
    |> Map.put(:cuota_actual, cuota_actual)
    |> Map.put(:pagado, pagado)
  end
end
