defmodule Mejora.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :total_amount, :decimal
      add :author, :string
      add :transaction_type, :string
      add :payment_date, :utc_datetime
      add :comments, :string
      add :association_type, :string
      add :association_id, :integer

      timestamps()
    end
  end
end
