defmodule Mejora.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :father_last_name, :string
      add :mother_last_name, :string
      add :cellphone_number, :string
      add :curp, :string
      add :rfc, :string
    end
  end
end
