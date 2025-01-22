defmodule Mejora.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :transaction_type, :string
      add :due_date, :date
      add :invoice_number, :string
      add :total, :decimal
      add :status, :string
      add :neighborhood_id, :integer
      add :property_id, :integer
      add :comments, :string
      add :metadata, :jsonb, default: "{}", null: false

      timestamps()
    end
  end
end
