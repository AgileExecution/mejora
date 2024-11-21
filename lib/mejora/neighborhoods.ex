defmodule Mejora.Neighborhoods do
  import Ecto.Query, warn: false

  alias Mejora.Neighborhoods.Neighborhood
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
end
