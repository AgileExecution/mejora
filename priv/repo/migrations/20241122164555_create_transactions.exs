defmodule Mejora.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :total_amount, :decimal
      add :author, :string
      add :transaction_type, :string
      add :payment_date, :utc_datetime
      add :comments, :string
      add :invoice_id, references(:invoices, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
