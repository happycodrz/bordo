defmodule Bordo.Repo.Migrations.CreateBrandTeams do
  use Ecto.Migration

  def change do
    create table(:brand_teams) do
      add :brand_id, references(:brands, on_delete: :nothing)
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:brand_teams, [:brand_id])
    create index(:brand_teams, [:team_id])
  end
end
