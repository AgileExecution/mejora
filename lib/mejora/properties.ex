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

  def list_properties_by_neighborhood(neighborhood_id) do
    Repo.all(
      from p in Property,
        where: p.neighborhood_id == ^neighborhood_id,
        select: %{
          id: p.id,
          street: p.street,
          number: p.number,
          status: p.status,
          paid: p.paid
        }
    )
  end

  def get_property!(id), do: Repo.get!(Property, id)

  def update_property(property, attrs) do
    property
    |> Property.changeset(attrs)
    |> Repo.update()
  end

  def get_properties(filters) do
    Property
    |> from()
    |> where(^dynamic_filters(filters))
    |> Repo.all()
  end

  defp dynamic_filters(filters) when is_list(filters),
    do: Enum.reduce(filters, dynamic(true), &filter_by/2)

  defp filter_by({:street, street}, dynamic),
    do: dynamic([t], ^dynamic and ilike(t.street, ^"%#{street}%"))

  defp filter_by({:number, number}, dynamic),
    do: dynamic([t], ^dynamic and ilike(t.number, ^"%#{number}%"))

  defp filter_by({_, _}, dynamic), do: dynamic
end
