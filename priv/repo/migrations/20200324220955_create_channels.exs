defmodule Bordo.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :uuid, :string
      add :auth_token, :string
      add :refresh_token, :string
      add :network, :string
      add :brand_id, references(:brands, on_delete: :delete_all)

      timestamps()
    end

    create index(:channels, [:brand_id])
  end
end
