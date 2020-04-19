defmodule Bordo.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :text
      add :token_secret, :text
      add :user_id, :string
      add :network, :string
      add :brand_id, references(:brands, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:channels, [:brand_id])
  end
end
