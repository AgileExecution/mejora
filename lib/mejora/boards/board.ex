defmodule Mejora.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:name, :start_date, :end_date, :status]

  schema "boards" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
  end
end
