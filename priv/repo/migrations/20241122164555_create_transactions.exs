defmodule Mejora.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :total_amount, :decimal
      add :author, :string
      add :transaction_type, :string
      add :payment_date, :utc_datetime
      add :comments, :string
      add :association_id, :integer, null: false
      add :association_type, :string, null: false

      timestamps()
    end

    create index(:transactions, [:association_id, :association_type])
  end
end
