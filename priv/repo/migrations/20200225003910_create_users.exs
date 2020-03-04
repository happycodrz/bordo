defmodule Bordo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string, null: false
      add :email, :string, null: false
      add :auth0_id, :string
      add :first_name, :string
      add :last_name, :string
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
    create index(:users, [:auth0_id])
  end
end
