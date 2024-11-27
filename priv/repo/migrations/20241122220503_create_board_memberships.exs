defmodule Mejora.Repo.Migrations.CreateBoardMemberships do
  use Ecto.Migration

  def change do
    create table(:board_memberships) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :board_id, references(:boards, on_delete: :nothing), null: false
      add :role, :string
    end
  end
end
