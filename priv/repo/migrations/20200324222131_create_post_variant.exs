defmodule Bordo.Repo.Migrations.CreatePostVariant do
  use Ecto.Migration

  def change do
    create table(:post_variants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :channel_id, references(:channels, type: :uuid, on_delete: :delete_all)
      add :external_id, :string
      add :post_id, references(:posts, type: :uuid, on_delete: :delete_all)
      add :content, :string, null: false
      add :status, :post_status, null: false, default: "draft"

      timestamps()
    end

    create index(:post_variants, [:channel_id])
    create index(:post_variants, [:post_id])
  end
end
