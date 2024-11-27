defmodule Mejora.Repo.Migrations.CreatePropertyMemberships do
  use Ecto.Migration

  def change do
    create table(:property_memberships) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :property_id, references(:properties, on_delete: :nothing), null: false
      add :role, :string

      timestamps()
    end
  end
end
