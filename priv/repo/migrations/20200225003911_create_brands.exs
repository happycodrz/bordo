defmodule Bordo.Repo.Migrations.CreateBrands do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add :uuid, :string, null: false, unique: true
      add :name, :string, null: false
      add :icon_url, :string

      timestamps()
    end

    unique_index(:brands, [:uuid])
  end
end
