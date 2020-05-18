defmodule Bordo.Repo.Migrations.AddStripeCustomerId do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :stripe_customer_id, :string
    end
  end
end
