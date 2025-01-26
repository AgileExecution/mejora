defmodule Mejora.Properties do
  import Ecto.Query, warn: false

  alias Mejora.Properties.Property
  alias Mejora.Repo

  def create_property(attrs) do
    %Property{}
    |> Property.changeset(attrs)
    |> Repo.insert()
  end

  def get_property(id) do
    Repo.get(Property, id)
  end

  def list_properties do
    Repo.all(Property)
  end

  def get_property!(id), do: Repo.get!(Property, id)

  def update_property(property, attrs) do
    property
    |> Property.changeset(attrs)
    |> Repo.update()
  end

  def get_properties(filters, order_by \\ []) do
    query =
      Property
      |> where(^dynamic_filters(filters))

    query =
      if order_by != [] do
        order_by(query, ^order_by)
      else
        query
      end

    query
    |> Repo.all()
    |> Repo.preload(:invoices)
  end

  defp dynamic_filters(filters) when is_list(filters) do
    Enum.reduce(filters, dynamic(true), fn filter, dynamic_query ->
      filter_by(filter, dynamic_query)
    end)
  end

  defp filter_by({:search_query, query}, dynamic) when not is_nil(query) and query != "" do
    like_query = "%#{query}%"

    dynamic([p], ^dynamic and (ilike(p.street, ^like_query) or ilike(p.number, ^like_query)))
  end

  defp filter_by({:search_query, _}, dynamic), do: dynamic

  defp filter_by({:neighborhood_id, neighborhood_id}, dynamic) when not is_nil(neighborhood_id) do
    dynamic([p], ^dynamic and p.neighborhood_id == ^neighborhood_id)
  end

  defp filter_by({:neighborhood_id, _}, dynamic), do: dynamic

  defp filter_by({_, _}, dynamic), do: dynamic
end
