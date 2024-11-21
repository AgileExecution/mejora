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
end
