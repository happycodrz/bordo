defmodule Bordo.Repo.Migrations.ChangeBrandUniqueConstraint do
  use Ecto.Migration

  def change do
    drop index(:brands, [:name])
    create unique_index(:brands, [:name, :team_id])
  end
end
