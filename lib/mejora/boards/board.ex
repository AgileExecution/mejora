defmodule Mejora.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string

    timestamps()
  end

  def changeset(property, attrs) do
    property
    |> cast(attrs, [:name, :start_date, :end_date, :status, :comments])
    |> validate_required([:name, :start_date, :end_date, :status])
  end
end
