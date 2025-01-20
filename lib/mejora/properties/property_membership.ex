defmodule Mejora.Properties.PropertyMembership do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mejora.Accounts.User
  alias Mejora.Properties.Property

  schema "property_memberships" do
    belongs_to :user, User
    belongs_to :property, Property

    field :role, Ecto.Enum, values: [:resident, :owner, :tenant], default: :owner

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:user_id, :property_id, :role])
  end

  def assoc_changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:property_id, :role])
  end
end
