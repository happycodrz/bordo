defmodule Bordo.Repo.Migrations.AddTimezoneToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:timezone, :string)
    end
  end
end
