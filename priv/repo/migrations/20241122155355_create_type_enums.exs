defmodule Mejora.Repo.Migrations.CreateTypeEnums do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE transaction_type AS ENUM ('sale', 'purchase', 'other')"
    execute "CREATE TYPE invoice_status AS ENUM ('unpaid', 'pending', 'cancelled', 'paid')"
  end

  def down do
    execute "DROP TYPE transation_type"
    execute "DROP TYPE invoice_status"
  end
end
