defmodule Bordo.Repo.Migrations.DropBrandsOwnerId do
  use Ecto.Migration

  def change do
    alter table(:brands) do
      remove :owner_id
    end
  end
end
