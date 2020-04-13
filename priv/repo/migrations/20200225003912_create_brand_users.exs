defmodule Bordo.Repo.Migrations.CreateBrandUsers do
  use Ecto.Migration

  def change do
    create table(:brand_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :brand_id, references(:brands, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:brand_users, [:brand_id])
    create index(:brand_users, [:user_id])
  end
end
