defmodule Bordo.Repo.Migrations.CreatePostVariant do
  use Ecto.Migration

  def change do
    create table(:post_variants) do
      add :uuid, :string
      add :channel_id, references(:channels, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)
      add :content, :string, null: false
      add :status, :post_status, null: false, default: "draft"

      timestamps()
    end

    create index(:post_variants, [:channel_id])
    create index(:post_variants, [:post_id])
  end
end
