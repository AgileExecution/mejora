defmodule Mejora.Repo.Migrations.CreateNeighborhoods do
  use Ecto.Migration

  def change do
    create table(:neighborhoods) do
      add :name, :string
      add :type, :string
      add :state, :string
      add :city, :string
      add :zipcode, :string
      add :email, :string
      add :total_count_properties, :integer
      add :total_count_active_properties, :integer
      add :comments, :string
      add :electoral_district, :string
      add :representative, :string
      add :bank_account, :string
      add :init_date, :date

      timestamps()
    end
  end
end
