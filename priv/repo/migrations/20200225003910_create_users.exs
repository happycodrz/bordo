defmodule Bordo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uuid, :string, null: false, unique: true
      add :email, :string, null: false, unique: true
      add :first_name, :string
      add :last_name, :string
      timestamps()
    end
  end
end
