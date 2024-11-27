defmodule Mejora.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string, null: false
      add :start_date, :date
      add :end_date, :date
      add :comments, :string
      add :status, :string, default: "active"

      timestamps()
    end
  end
end
