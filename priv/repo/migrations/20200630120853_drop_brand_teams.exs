defmodule Bordo.Repo.Migrations.DropBrandTeams do
  use Ecto.Migration

  def change do
    drop table(:brand_teams)
  end
end
