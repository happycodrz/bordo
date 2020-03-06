defmodule Bordo.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :string
      add :s3_path, :string
      add :s3_object_name, :string

      timestamps()
    end

  end
end
