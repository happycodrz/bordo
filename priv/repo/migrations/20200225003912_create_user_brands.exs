defmodule Bordo.Repo.Migrations.CreateUserBrands do
  use Ecto.Migration

  def change do
    create table(:user_brands) do
      add :brand_id, references(:brands, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_brands, [:brand_id])
    create index(:user_brands, [:user_id])
  end
end
