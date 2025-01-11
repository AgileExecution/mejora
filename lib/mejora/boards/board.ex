defmodule Mejora.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Board

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

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields)

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Board{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key) when key == "Acta Constitutiva (archivo PDF)", do: :constitutive_act
  defp to_atom(key), do: String.to_atom(key)
end
