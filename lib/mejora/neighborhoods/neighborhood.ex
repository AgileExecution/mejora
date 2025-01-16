defmodule Mejora.Neighborhoods.Neighborhood do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__, as: Neighborhood

  @required_fields [
    :name,
    :type,
    :state,
    :city,
    :zipcode,
    :email
  ]

  schema "neighborhoods" do
    field :name, :string
    field :type, :string
    field :state, :string
    field :city, :string
    field :zipcode, :string
    field :email, :string
    field :representative, :string
    field :init_date, :date
    field :bank_account, :string
    field :electoral_district, :string
    field :total_count_properties, :integer
    field :total_count_active_properties, :integer
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

  def edit_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Neighborhood{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc ->
        acc

      {"Distrito Electoral", value}, acc ->
        Map.put(acc, :electoral_district, parse_as(value, :string))

      {"Código Postal", value}, acc ->
        Map.put(acc, :zipcode, parse_as(value, :string))

      {"Fecha de Alta", value}, acc ->
        Map.put(acc, :init_date, parse_as(value, :date))

      {key, value}, acc ->
        Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key) when key == "Ciudad", do: :city
  defp to_atom(key) when key == "Código Postal", do: :zipcode
  defp to_atom(key) when key == "Email", do: :email
  defp to_atom(key) when key == "Estado", do: :state
  defp to_atom(key) when key == "Nombre de la Colonia", do: :name
  defp to_atom(key) when key == "Tipo de Colonia", do: :type
  defp to_atom(key) when key == "Fecha de Alta", do: :init_date
  defp to_atom(key) when key == "Saldo Cuenta Bancaria", do: :bank_account
  defp to_atom(key) when key == "Distrito Electoral", do: :electoral_district
  defp to_atom(key) when key == "Diputado", do: :representative

  defp to_atom(key), do: String.to_atom(key)

  defp parse_as(nil, :string), do: ""
  defp parse_as(value, :string) when is_bitstring(value), do: value
  defp parse_as(value, :string) when is_integer(value), do: Integer.to_string(value)
  defp parse_as(value, :date) when is_integer(value), do: Timex.shift(~D[1900-01-01], days: value)
end
