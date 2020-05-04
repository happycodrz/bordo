defmodule Bordo.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :last_paid_at, :naive_datetime

      add :owner_id, references(:users, column: :id, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    alter table("users") do
      add :team_id, references(:teams, type: :uuid, on_delete: :delete_all)
    end

    create index(:users, [:team_id])
    create index(:teams, [:owner_id])
  end
end
