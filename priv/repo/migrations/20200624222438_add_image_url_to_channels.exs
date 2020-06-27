defmodule Bordo.Repo.Migrations.AddImageUrlToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :image_url, :string
    end
  end
end
