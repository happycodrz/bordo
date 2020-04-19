defmodule Bordo.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:media, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :brand_id, references(:brands, type: :uuid, on_delete: :nothing), null: false
      add :title, :string
      add :public_id, :string, null: false
      add :url, :string, null: false
      add :thumbnail_url, :string, null: false
      add :bytes, :integer, null: false
      add :width, :integer, null: false
      add :height, :integer, null: false
      add :resource_type, :string, null: false

      timestamps()
    end
  end
end
