defmodule Bordo.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :uuid, :string, null: false, unique: true
      add :name, :string, null: false
      add :owner_id, references(:users, column: :id, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:teams, [:owner_id])
  end
end
