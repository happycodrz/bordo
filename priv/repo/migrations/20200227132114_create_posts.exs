defmodule Bordo.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :status, :post_status, null: false, default: "draft"
      add :uuid, :string, null: false, unique: true
      add :scheduled_for, :datetime
      add :brand_id, references(:brands, on_delete: :nothing), null: false
      add :user_id, references(:users, column: :id, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:posts, [:brand_id])
    create index(:posts, [:user_id])
  end
end
