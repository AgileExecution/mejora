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

  def changeset(property_membership, attrs) do
    property_membership
    |> cast(attrs, [:user_id, :property_id, :role])
    |> validate_required([:user_id, :property_id, :role])
  end
end
