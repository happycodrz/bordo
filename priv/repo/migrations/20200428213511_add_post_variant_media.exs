defmodule Bordo.Repo.Migrations.AddPostVariantMedia do
  use Ecto.Migration

  def change do
    create table(:post_variant_media, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :post_variant_id, references(:post_variants, type: :uuid, on_delete: :delete_all),
        null: false

      add :media_id, references(:media, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:post_variant_media, [:post_variant_id, :media_id])
  end
end
