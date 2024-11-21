defmodule Mejora.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties) do
      add :street, :string
      add :number, :string
      add :status, :string
      add :comments, :string

      timestamps()
    end
  end
end
