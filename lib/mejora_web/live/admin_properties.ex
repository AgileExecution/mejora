defmodule MejoraWeb.Live.AdminProperties do
  use MejoraWeb, :live_view

  alias Mejora.Neighborhoods
  alias Mejora.Properties
  alias Mejora.Accounts.User
  alias Mejora.Neighborhoods.Quota

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    case User.get_neighborhood_from_property_membership(current_user) do
      {:ok, neighborhood} ->
        monthly_quota = Neighborhoods.current_quota(neighborhood.id)
        neighborhood_quota = Neighborhoods.expected_monthly_quota(neighborhood.id)

        filter = [{:neighborhood_id, neighborhood.id}]
        per_page = 10

        all_properties =
          Properties.get_properties(filter, asc: :street, asc: :number)
          |> Enum.map(&add_status_to_property(&1, neighborhood.id))

        property_count = length(all_properties)
        total_pages = Float.ceil(property_count / per_page) |> trunc()

        {:ok,
         socket
         |> assign(:properties, paginate_properties(all_properties, 1, per_page))
         |> assign(:all_properties, all_properties)
         |> assign(:monthly_quota, monthly_quota)
         |> assign(:property_count, property_count)
         |> assign(:neighborhood_quota, neighborhood_quota)
         |> assign(:neighborhood, neighborhood.id)
         |> assign(:search_query, "")
         |> assign(:selected_status, "")
         |> assign(:current_page, 1)
         |> assign(:per_page, 10)
         |> assign(:total_pages, total_pages)}

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
         |> assign(:selected_status, "")
         |> assign(:current_page, 1)
         |> assign(:per_page, 10)
         |> assign(:total_pages, 1)}
    end
  end

  def mount(_params, _session, socket),
    do:
      {:ok,
       socket
       |> redirect(to: "/login")
       |> put_flash(:error, "Inicia sesión para continuar.")
       |> assign(:search_query, "")}

  defp paginate_properties(properties, page, per_page) do
    properties
    |> Enum.drop((page - 1) * per_page)
    |> Enum.take(per_page)
  end

  @impl true
  def handle_event("per_page_change", %{"per_page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    selected_status = socket.assigns.selected_status
    search_query = socket.assigns.search_query

    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        (String.contains?(String.downcase(property.street || ""), String.downcase(search_query)) or
           String.contains?(String.downcase(property.number || ""), String.downcase(search_query))) and
          (selected_status == "" or property.status_es == selected_status)
      end)

    total_count = length(filtered_properties)
    total_pages = max(Float.ceil(total_count / per_page) |> trunc(), 1)

    paginated_properties = paginate_properties(filtered_properties, 1, per_page)

    {:noreply,
     socket
     |> assign(:per_page, per_page)
     |> assign(:total_pages, total_pages)
     |> assign(:properties, paginated_properties)
     |> assign(:current_page, 1)}
  end

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    property = Properties.get_property!(String.to_integer(id))

    new_status = if property.status == :active, do: :inactive, else: :active

    case Properties.update_property(property, %{status: new_status}) do
      {:ok, updated_property} ->
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
        {:noreply, socket |> put_flash(:error, "No se pudo cambiar el estado de la propiedad.")}
    end
  end

  @impl true
  def handle_event("filter_properties", %{"value" => query}, socket) do
    normalized_query = String.trim(query)
    selected_status = socket.assigns.selected_status
    per_page = socket.assigns.per_page

    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        (String.contains?(
           String.downcase(property.street || ""),
           String.downcase(normalized_query)
         ) or
           String.contains?(
             String.downcase(property.number || ""),
             String.downcase(normalized_query)
           )) and
          (selected_status == "" or property.status_es == selected_status)
      end)

    total_count = length(filtered_properties)
    total_pages = max(Float.ceil(total_count / per_page) |> trunc(), 1)

    paginated_properties = paginate_properties(filtered_properties, 1, per_page)

    {:noreply,
     socket
     |> assign(:properties, paginated_properties)
     |> assign(:search_query, normalized_query)
     |> assign(:total_pages, total_pages)
     |> assign(:current_page, 1)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    normalized_query = socket.assigns.search_query
    per_page = socket.assigns.per_page

    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        (String.contains?(
           String.downcase(property.street || ""),
           String.downcase(normalized_query)
         ) or
           String.contains?(
             String.downcase(property.number || ""),
             String.downcase(normalized_query)
           )) and
          (status == "" or property.status_es == status)
      end)

    total_count = length(filtered_properties)
    total_pages = max(Float.ceil(total_count / per_page) |> trunc(), 1)

    paginated_properties = paginate_properties(filtered_properties, 1, per_page)

    {:noreply,
     socket
     |> assign(:properties, paginated_properties)
     |> assign(:selected_status, status)
     |> assign(:total_pages, total_pages)
     |> assign(:current_page, 1)}
  end

  @impl true
  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    per_page = socket.assigns.per_page
    selected_status = socket.assigns.selected_status
    search_query = socket.assigns.search_query

    # Aplicar filtros antes de paginar
    filtered_properties =
      socket.assigns.all_properties
      |> Enum.filter(fn property ->
        (String.contains?(String.downcase(property.street || ""), String.downcase(search_query)) or
           String.contains?(String.downcase(property.number || ""), String.downcase(search_query))) and
          (selected_status == "" or property.status_es == selected_status)
      end)

    total_pages = max(Float.ceil(length(filtered_properties) / per_page) |> trunc(), 1)

    page = max(1, min(page, total_pages))

    paginated_properties = paginate_properties(filtered_properties, page, per_page)

    {:noreply,
     socket
     |> assign(:selected_status, selected_status)
     |> assign(:properties, paginated_properties)
     |> assign(:total_pages, total_pages)
     |> assign(:current_page, page)}
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
      case Mejora.Properties.Status.get_property_status(property.id) do
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

          transactions_total = Mejora.Properties.Status.get_transactions_total(property.id)
          expected_amount = Mejora.Properties.Status.get_expected_amount(property.id)

          monthly_quota =
            case Neighborhoods.current_quota(neighborhood_id) do
              %Quota{amount: amount} -> amount
              _ -> Decimal.new(0)
            end

          paid_months_compare =
            if Decimal.gt?(monthly_quota, Decimal.new(0)) do
              Decimal.div(transactions_total, monthly_quota)
              |> Decimal.round(0, :down)
              |> Decimal.to_integer()
            else
              0
            end

          expected_months =
            if Decimal.gt?(monthly_quota, Decimal.new(0)) do
              Decimal.div(expected_amount, monthly_quota)
              |> Decimal.round(0, :down)
              |> Decimal.to_integer()
            else
              0
            end

          paid_months =
            cond do
              Decimal.compare(transactions_total, expected_amount) == :gt ->
                "+#{paid_months_compare - expected_months}"

              Decimal.compare(transactions_total, expected_amount) == :eq ->
                "0"

              Decimal.compare(transactions_total, expected_amount) == :lt ->
                "-#{expected_months - paid_months_compare}"

              true ->
                "0"
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
