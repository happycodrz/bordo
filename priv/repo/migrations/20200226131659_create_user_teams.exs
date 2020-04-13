defmodule Bordo.Repo.Migrations.CreateUserTeams do
  use Ecto.Migration

  def change do
    create table(:user_teams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :team_id, references(:teams, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_teams, [:team_id])
    create index(:user_teams, [:user_id])
  end
end
