defmodule Mejora.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

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
end
