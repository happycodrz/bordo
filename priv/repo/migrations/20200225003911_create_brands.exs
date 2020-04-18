defmodule Bordo.Repo.Migrations.CreateBrands do
  use Ecto.Migration

  def change do
    create table(:brands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false, unique: true
      add :name, :string, null: false

      add :owner_id, references(:users, column: :id, type: :uuid, on_delete: :nothing),
        null: false

      timestamps()
    end

    create unique_index(:brands, [:name])
    create unique_index(:brands, [:slug])
    create index(:brands, [:owner_id])
  end
end
