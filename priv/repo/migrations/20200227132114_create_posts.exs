defmodule Bordo.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :integer, null: false, unique: true
      add :scheduled_for, :utc_datetime
      add :brand_id, references(:brands, type: :uuid, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :uuid, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:posts, [:brand_id])
    create index(:posts, [:user_id])
    create unique_index(:posts, [:brand_id, :slug])
  end
end
