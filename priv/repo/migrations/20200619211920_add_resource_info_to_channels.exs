defmodule Bordo.Repo.Migrations.AddResourceInfoToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add(:resource_info, :jsonb, default: "{}")
    end
  end
end
