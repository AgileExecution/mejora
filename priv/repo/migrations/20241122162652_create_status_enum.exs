defmodule Mejora.Repo.Migrations.CreateStatusEnum do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE status AS ENUM ('active', 'inactive')"
  end

  def down do
    execute "DROP TYPE status"
  end
end
