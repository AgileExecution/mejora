defmodule Mejora.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Provider

  schema "providers" do
    field :name, :string
    field :rfc, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :description, :string
    field :bank_account, :string
    field :address, :string
    field :legal_name, :string

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:name])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields)

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Provider{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  defp to_atom(key) when key == "Cuenta CLABE", do: :clabe
  defp to_atom(key), do: String.to_atom(key)
end
