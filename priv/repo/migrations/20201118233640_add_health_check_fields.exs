defmodule Bordo.Repo.Migrations.AddHealthCheckFields do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :health_last_checked_at, :naive_datetime
      add :needs_reauthentication, :boolean, default: false
    end
  end
end
