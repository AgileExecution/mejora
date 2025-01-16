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
    field :index, :integer, virtual: true

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

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
      {"Fecha Final", value}, acc -> Map.put(acc, :end_date, parse_as(value, :date))
      {"Fecha de Inicio", value}, acc -> Map.put(acc, :start_date, parse_as(value, :date))
      {"Estatus", value}, acc -> Map.put(acc, :status, parse_as(value, :atom))
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key) when key == "Acta Constitutiva (archivo PDF)", do: :constitutive_act
  defp to_atom(key) when key == "Comentarios", do: :comments
  defp to_atom(key) when key == "Nombre de la Mesa", do: :name
  defp to_atom(key), do: String.to_atom(key)

  defp parse_as(nil, :string), do: ""
  defp parse_as("Inactiva", :atom), do: :inactive
  defp parse_as("Activa", :atom), do: :active
  defp parse_as(value, :date) when is_bitstring(value), do: Timex.shift(Timex.now(), months: 12)
  defp parse_as(value, :date) when is_integer(value), do: Timex.shift(~D[1900-01-01], days: value)
end
