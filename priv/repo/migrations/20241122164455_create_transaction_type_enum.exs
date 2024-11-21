defmodule Mejora.Repo.Migrations.CreateTransactionTypeEnum do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE transaction_type AS ENUM ('income', 'outcome')"
  end

  def down do
    execute "DROP TYPE transation_type"
  end
end
