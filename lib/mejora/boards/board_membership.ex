defmodule Mejora.Boards.BoardMembership do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mejora.Accounts.User
  alias Mejora.Boards.Board

  schema "board_memberships" do
    belongs_to :user, User
    belongs_to :board, Board

    field :role, Ecto.Enum,
      values: [:president, :secretary, :treasurer, :vocal_one, :vocal_two, :vocal_three],
      default: :president

    timestamps()
  end

  def changeset(property_membership, attrs) do
    property_membership
    |> cast(attrs, [:user_id, :board_id, :role])
    |> validate_required([:user_id, :board_id, :role])
  end
end
