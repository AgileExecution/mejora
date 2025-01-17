defmodule MejoraWeb.Live.AdminProperties do
  use MejoraWeb, :live_view

  alias Mejora.Properties

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    if current_user do
      properties =
        Properties.list_properties_by_neighborhood(current_user.neighborhood_id)
        |> Enum.map(&assign_status_class(&1))
        cuota_mensual = 350.00
        numero_propiedades = length(properties)
        cuota_colonia = cuota_mensual * numero_propiedades
      {:ok,
       socket
       |> assign(:properties, properties)
       |> assign(:cuota_mensual, cuota_mensual)
       |> assign(:numero_propiedades, numero_propiedades)
       |> assign(:cuota_colonia, cuota_colonia)}
    else
      {:ok,
       socket
       |> redirect(to: "/login")
       |> put_flash(:error, "Inicia sesión para continuar.")}
    end
  end

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    property = Properties.get_property!(id)
    new_status = if property.status == :active, do: :inactive, else: :active
    Properties.update_property(property, %{status: new_status})

    updated_properties =
      Properties.list_properties_by_neighborhood(socket.assigns.current_user.neighborhood_id)
      |> Enum.map(&assign_status_class(&1))

    {:noreply, assign(socket, :properties, updated_properties)}
  end

  defp assign_status_class(property) do
    current_date = ~D[2023-05-14] #Date.utc_today()
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
    case Float.parse(property.paid || "0") do
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
