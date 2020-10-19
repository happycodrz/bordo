defmodule Bordo.Repo.Migrations.CreateChannelWebhooks do
  use Ecto.Migration

  def change do
    create table(:channel_webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :external_id, :string, null: false
      add :webhook_url, :string, null: false

      add :channel_id, references(:channels, column: :id, type: :uuid, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:channel_webhooks, [:channel_id])
    create unique_index(:channel_webhooks, [:external_id])
  end
end
