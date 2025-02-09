defmodule MejoraWeb.Live.AdminProperties do
  use MejoraWeb, :live_view

  alias Mejora.Neighborhoods
  alias Mejora.Properties
  alias Mejora.Properties.Status
  alias Mejora.Accounts.User
  alias Mejora.Neighborhoods.Quota

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    case User.get_neighborhood_from_property_membership(current_user) do
      {:ok, neighborhood} ->
        monthly_quota = Neighborhoods.current_quota(neighborhood.id)
        neighborhood_quota = Neighborhoods.expected_monthly_quota(neighborhood.id)

        filter = [{:neighborhood_id, neighborhood.id}]

        properties =
          Properties.get_properties(filter, asc: :street, asc: :number)
          |> Enum.map(&add_status_to_property(&1, neighborhood.id))

        property_count = length(properties)

        {:ok,
         socket
         |> assign(:properties, properties)
         |> assign(:all_properties, properties)
         |> assign(:monthly_quota, monthly_quota)
         |> assign(:property_count, property_count)
         |> assign(:neighborhood_quota, neighborhood_quota)
         |> assign(:neighborhood, neighborhood.id)
         |> assign(:search_query, "")
         |> assign(:selected_status, "")}

      {:error, _reason} ->
        {:ok,
         socket
         |> put_flash(:error, "No se pudo obtener el vecindario.")
         |> assign(:properties, [])
         |> assign(:all_properties, [])
         |> assign(:property_count, 0)
         |> assign(:monthly_quota, %{amount: 0})
         |> assign(:neighborhood_quota, 0)
         |> assign(:neighborhood, nil)
         |> assign(:search_query, "")
         |> assign(:selected_status, "")}
    end
  end

  def mount(_params, _session, socket),
    do:
      {:ok,
       socket
       |> redirect(to: "/login")
       |> put_flash(:error, "Inicia sesión para continuar.")
       |> assign(:search_query, "")}

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    # Busca la propiedad en la base de datos
    property = Properties.get_property!(String.to_integer(id))

    # Cambia el estado de la propiedad
    new_status = if property.status == :active, do: :inactive, else: :active

    # Actualiza la propiedad en la base de datos
    case Properties.update_property(property, %{status: new_status}) do
      {:ok, updated_property} ->
        # Actualiza la lista de propiedades en el socket
        updated_properties =
          Enum.map(socket.assigns.properties, fn p ->
            if p.id == updated_property.id do
              Map.put(p, :active_status, updated_property.status)
            else
              p
            end
          end)

        {:noreply, assign(socket, :properties, updated_properties)}

      {:error, _changeset} ->
        # Si ocurre un error, muestra un mensaje en la interfaz
        {:noreply, socket |> put_flash(:error, "No se pudo cambiar el estado de la propiedad.")}
    end
  end

  @impl true
  def handle_event("filter_properties", %{"value" => query}, socket) do
    normalized_query = String.trim(query)
    selected_status = socket.assigns.selected_status

    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        String.contains?(
          String.downcase(property.street || ""),
          String.downcase(normalized_query)
        ) or
          String.contains?(
            String.downcase(property.number || ""),
            String.downcase(normalized_query)
          )
      end)

    filtered_properties =
      if selected_status != "" do
        Enum.filter(filtered_properties, fn property -> property.status_es == selected_status end)
      else
        filtered_properties
      end

    {:noreply,
     socket
     |> assign(:properties, filtered_properties)
     |> assign(:search_query, normalized_query)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    normalized_query = socket.assigns.search_query

    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        String.contains?(
          String.downcase(property.street || ""),
          String.downcase(normalized_query)
        ) or
          String.contains?(
            String.downcase(property.number || ""),
            String.downcase(normalized_query)
          )
      end)

    filtered_properties =
      if status != "" do
        Enum.filter(filtered_properties, fn property -> property.status_es == status end)
      else
        filtered_properties
      end

    {:noreply,
     socket
     |> assign(:properties, filtered_properties)
     |> assign(:selected_status, status)}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: "Evento recibido no manejado")
    {:noreply, socket}
  end

  defp add_status_to_property(property, neighborhood_id) do
    if is_nil(neighborhood_id) do
      property
      |> Map.put(:status, "unknown")
      |> Map.put(:status_class, "unknown")
      |> Map.put(:status_es, "Estado desconocido")
      |> Map.put(:payment_status, "Saldo desconocido")
      |> Map.put(:active_status, "unknown")
      |> Map.put(:toggle_action, "Activar")
      |> Map.put(:paid_months, 0)
    else
      case Status.get_property_status(property.id) do
        {:ok, status} ->
          status_class =
            case status do
              :current -> "current"
              :late -> "late"
              :advance -> "advance"
            end

          status_es =
            case status do
              :current -> "Al corriente"
              :late -> "Atrasado"
              :advance -> "Adelantado"
            end

          transactions_total = Status.get_transactions_total(property.id)
          expected_amount = Status.get_expected_amount(property.id)

          monthly_quota =
            case Neighborhoods.current_quota(neighborhood_id) do
              %Quota{amount: amount} -> amount
              _ -> Decimal.new(0)
            end

          paid_months_compare =
            cond do
              Decimal.compare(transactions_total, expected_amount) != :lt ->
                Decimal.div(transactions_total, monthly_quota)
                |> Decimal.round(0, :down)
                |> Decimal.to_integer()
                |> Kernel.-(1)

              Decimal.compare(transactions_total, expected_amount) == :lt ->
                Decimal.div(transactions_total, monthly_quota)
                |> Decimal.round(0, :down)
                |> Decimal.to_integer()
                |> Kernel.-(1)
            end

          paid_months =
            if paid_months_compare > 0 do
              "+#{paid_months_compare}"
            else
              "#{paid_months_compare}"
            end

          payment_status = "$#{Decimal.to_string(transactions_total)}"

          active_status = property.status
          toggle_action = if active_status == :active, do: "Desactivar", else: "Activar"

          property
          |> Map.put(:status, status)
          |> Map.put(:status_class, status_class)
          |> Map.put(:status_es, status_es)
          |> Map.put(:payment_status, payment_status)
          |> Map.put(:active_status, active_status)
          |> Map.put(:toggle_action, toggle_action)
          |> Map.put(:paid_months, paid_months)

        {:error, _reason} ->
          property
          |> Map.put(:status, "unknown")
          |> Map.put(:status_class, "unknown")
          |> Map.put(:status_es, "Estado desconocido")
          |> Map.put(:payment_status, "Saldo desconocido")
          |> Map.put(:active_status, "unknown")
          |> Map.put(:toggle_action, "Activar")
          |> Map.put(:paid_months, 0)
      end
    end
  end
end
