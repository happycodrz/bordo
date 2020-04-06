defmodule Bordo.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :uuid, :string
      add :token, :string
      add :token_secret, :string
      add :user_id, :string
      add :network, :string
      add :brand_id, references(:brands, on_delete: :delete_all)

      timestamps()
    end

    create index(:channels, [:brand_id])
  end
end
