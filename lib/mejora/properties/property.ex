defmodule Mejora.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Property

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

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields)

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Property{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key), do: String.to_atom(key)
end
