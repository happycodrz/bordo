defmodule Bordo.Repo.Migrations.AddStripeSubscriptionItemId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:stripe_subscription_id, :string)
    end
  end
end
