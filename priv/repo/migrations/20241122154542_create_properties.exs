defmodule Mejora.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties) do
      add :street, :string
      add :number, :string
      add :status, :string
      add :comments, :string
      add :neighborhood_id, references(:neighborhoods, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
