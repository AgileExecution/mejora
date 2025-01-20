defmodule Mejora.Repo.Migrations.CreateQuotas do
  use Ecto.Migration

  def change do
    create table(:quotas) do
      add :amount, :decimal
      add :start_date, :date
      add :end_date, :date
      add :status, :string
      add :comments, :string
      add :neighborhood_id, references(:neighborhoods, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
