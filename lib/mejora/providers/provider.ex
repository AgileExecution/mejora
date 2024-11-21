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

  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [:name, :rfc, :status, :description, :bank_account])
    |> validate_required([:name])
  end
end
