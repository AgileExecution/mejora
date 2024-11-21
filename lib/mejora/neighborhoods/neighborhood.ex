defmodule Mejora.Neighborhoods.Neighborhood do
  use Ecto.Schema

  import Ecto.Changeset

  schema "neighborhoods" do
    field :name, :string
    field :commercial_name, :string
    field :type, :string
    field :state, :string
    field :city, :string
    field :zipcode, :string
    field :email, :string
    field :total_count_properties, :integer
    field :total_count_active_properties, :integer
    field :comments, :string

    timestamps()
  end

  def changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [
      :name,
      :commercial_name,
      :type,
      :state,
      :city,
      :zipcode,
      :email,
      :total_count_active_properties,
      :total_count_properties,
      :comments
    ])
    |> validate_required([
      :name,
      :commercial_name,
      :type,
      :state,
      :city,
      :zipcode,
      :email
    ])
  end

  def edit_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
