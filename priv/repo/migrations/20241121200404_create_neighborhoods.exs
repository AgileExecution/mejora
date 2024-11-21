defmodule Mejora.Repo.Migrations.CreateNeighborhoods do
  use Ecto.Migration

  def change do
    create table(:neighborhoods) do
      add :name, :string
      add :commercial_name, :string
      add :type, :string
      add :state, :string
      add :city, :string
      add :zipcode, :string
      add :email, :string
      add :total_count_properties, :integer
      add :total_count_active_properties, :integer
      add :comments, :string

      timestamps()
    end
  end
end
