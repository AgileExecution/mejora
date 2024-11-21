defmodule Mejora.Repo.Migrations.CreateTransactionRows do
  use Ecto.Migration

  def change do
    create table(:transaction_rows) do
      add :amount, :decimal
      add :date, :date
      add :transaction_id, references(:transactions, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:transaction_rows, [:transaction_id])
  end
end
