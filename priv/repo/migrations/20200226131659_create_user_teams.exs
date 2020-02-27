defmodule Bordo.Repo.Migrations.CreateUserTeams do
  use Ecto.Migration

  def change do
    create table(:user_teams) do
      add :brand_id, references(:brands, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_teams, [:brand_id])
    create index(:user_teams, [:user_id])
  end
end
