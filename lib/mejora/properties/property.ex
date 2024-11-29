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

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:street, :number])
  end
end
