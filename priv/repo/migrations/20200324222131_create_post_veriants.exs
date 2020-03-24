defmodule Bordo.Repo.Migrations.CreatePostVeriants do
  use Ecto.Migration

  def change do
    create table(:post_variants) do
      add :uuid, :string
      add :channel_id, references(:channels, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:post_variants, [:channel_id])
    create index(:post_variants, [:post_id])
  end
end
