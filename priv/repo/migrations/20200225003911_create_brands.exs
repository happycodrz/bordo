defmodule Bordo.Repo.Migrations.CreateBrands do
  use Ecto.Migration

  def change do
    create table(:brands) do
      add :uuid, :string, null: false, unique: true
      add :name, :string, null: false
      add :owner_id, references(:users, column: :id, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
