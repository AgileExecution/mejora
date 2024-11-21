defmodule Mejora.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :name, :string
      add :rfc, :string
      add :status, :string, default: "active"
      add :description, :string
      add :bank_account, :string

      timestamps()
    end
  end
end
