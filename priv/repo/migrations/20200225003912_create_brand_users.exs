defmodule Bordo.Repo.Migrations.CreateBrandUsers do
  use Ecto.Migration

  def change do
    create table(:brand_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :brand_id, references(:brands, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:brand_users, [:brand_id, :user_id])
  end
end
