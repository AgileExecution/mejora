defmodule Mejora.Repo.Migrations.AddFieldsToProviders do
  use Ecto.Migration

  def change do
    alter table(:providers) do
      add :street, :string
      add :legal_name, :string
    end
  end
end
