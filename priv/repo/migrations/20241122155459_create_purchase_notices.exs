defmodule Mejora.Repo.Migrations.CreatePurchaseNotices do
  use Ecto.Migration

  def change do
    create table(:purchase_notices) do
      add :due_date, :date
      add :invoice_number, :string
      add :total, :decimal
      add :status, :string
      add :neighborhood_id, :integer
      add :comments, :string
      add :metadata, :jsonb, default: "{}", null: false

      timestamps()
    end
  end
end
