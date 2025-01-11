defmodule Mejora.Neighborhoods.Neighborhood do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__, as: Neighborhood

  @required_fields [
    :name,
    :commercial_name,
    :type,
    :state,
    :city,
    :zipcode,
    :email
  ]

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
    fields = __schema__(:fields)

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Neighborhood{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, String.to_atom(key), value)
    end)
  end
end
