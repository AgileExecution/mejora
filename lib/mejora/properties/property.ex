defmodule Mejora.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Property

  schema "properties" do
    field :street, :string
    field :number, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string
    field :index, :integer, virtual: true

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:street, :number])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]
    IO.inspect(record)

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
      {"Estatus", value}, acc -> Map.put(acc, :status, parse_as(value, :atom))
      {"Numero", value}, acc -> Map.put(acc, :number, parse_as(value, :string))
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key) when key == "Calle", do: :street
  defp to_atom(key) when key == "Comentarios", do: :comments
  defp to_atom(key) when key == "Numero", do: :number
  defp to_atom(key), do: String.to_atom(key)

  defp parse_as(nil, :string), do: ""
  defp parse_as("Inactiva", :atom), do: :inactive
  defp parse_as("Activa", :atom), do: :active
  defp parse_as(value, :string) when is_integer(value), do: Integer.to_string(value)
end
