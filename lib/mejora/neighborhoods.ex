defmodule Mejora.Neighborhoods do
  import Ecto.Query, warn: false

  alias Mejora.Neighborhoods.{Neighborhood, Quota}
  alias Mejora.Properties.Property
  alias Mejora.Repo

  def get(id) do
    Repo.get(Neighborhood, id)
  end

  def create_neighborhood(attrs) do
    %Neighborhood{}
    |> Neighborhood.changeset(attrs)
    |> Repo.insert()
  end

  def edit_neighborhood(%Neighborhood{} = neighborhood, attrs) do
    neighborhood
    |> Neighborhood.edit_changeset(attrs)
    |> Repo.update()
  end

  def edit_neighborhood(id, attrs) do
    id
    |> get()
    |> case do
      nil ->
        IO.inspect("Not found")

      record ->
        edit_neighborhood(record, attrs)
    end
  end

  def delete_neighborhood(id) do
    id
    |> get()
    |> case do
      nil ->
        IO.inspect("Not found")

      record ->
        Repo.delete(record)
    end
  end

  def get_all do
    Repo.all(Neighborhood)
  end

  def current_quota(neighborhood_id),
    do:
      Quota
      |> from()
      |> where(neighborhood_id: ^neighborhood_id, status: :active)
      |> Repo.one()

  def get_properties(neighborhood_id),
    do: Mejora.Properties.get_properties(neighborhood_id: neighborhood_id)

  def current_property_count(neighborhood_id) do
    Property
    |> from()
    |> where([p], p.neighborhood_id == ^neighborhood_id)
    |> select([p], count(p.id))
    |> Repo.one()
  end

  def expected_monthly_quota(neighborhood_id) do
    monthly_quota = current_quota(neighborhood_id)
    property_count = current_property_count(neighborhood_id)
    Decimal.mult(Decimal.new(monthly_quota.amount), Decimal.new(property_count))
  end
end
