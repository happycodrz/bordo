defmodule Bordo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
