defmodule Mejora.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset

  schema "properties" do
    field :street, :string
    field :number, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string

    timestamps()
  end

  def changeset(property, attrs) do
    property
    |> cast(attrs, [:street, :number, :status, :comments])
    |> validate_required([:street, :number])
  end
end
