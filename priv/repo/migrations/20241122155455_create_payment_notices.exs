defmodule Mejora.Repo.Migrations.CreatePaymentNotices do
  use Ecto.Migration

  def change do
    create table(:payment_notices) do
      add :due_date, :date
      add :invoice_number, :string
      add :total, :decimal
      add :status, :string
      add :property_id, :integer
      add :comments, :string
      add :metadata, :jsonb, default: "{}", null: false

      timestamps()
    end
  end
end
