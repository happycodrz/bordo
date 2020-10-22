defmodule Bordo.Repo.Migrations.AddTrialBannerAcknowledgedAt do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:trial_banner_acknowledged_at, :naive_datetime)
      add(:is_paid_customer, :boolean, default: false)
    end
  end
end
