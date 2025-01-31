defmodule Mejora.Repo.Migrations.AddNeighborhoodIdToBoards do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :neighborhood_id, references(:neighborhoods)
    end
  end
end
