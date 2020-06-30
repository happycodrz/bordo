defmodule Bordo.Repo.Migrations.AddTeamIdToBrands do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      add :team_id, references(:teams, column: :id, type: :uuid, on_delete: :delete_all)
    end
  end
end
