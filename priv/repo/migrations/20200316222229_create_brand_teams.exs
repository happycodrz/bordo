defmodule Bordo.Repo.Migrations.CreateBrandTeams do
  use Ecto.Migration

  def change do
    create table(:brand_teams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :brand_id, references(:brands, type: :uuid, on_delete: :delete_all)
      add :team_id, references(:teams, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:brand_teams, [:brand_id, :team_id])
  end
end
