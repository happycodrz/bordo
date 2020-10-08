defmodule Bordo.Repo.Migrations.CascadeDeleteMedia do
  use Ecto.Migration

  def change do
    alter table(:media) do
      modify :brand_id, references(:brands, column: :id, type: :uuid, on_delete: :delete_all), from: references(:brands)
    end
  end
end
