defmodule Bordo.Teams.Team do
  use Bordo.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :last_paid_at, :naive_datetime
    field :trial_banner_acknowledged_at, :naive_datetime
    field :stripe_customer_id, :string
    field :stripe_subscription_id, :string
    field :completed_onboarding, :boolean, default: false
    field :is_paid_customer, :boolean, default: false

    field :timezone, :string, default: "America/Chicago"
    belongs_to :owner, Bordo.Users.User
    has_many :brands, Bordo.Brands.Brand

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :completed_onboarding,
      :name,
      :owner_id,
      :is_paid_customer,
      :stripe_customer_id,
      :stripe_subscription_id,
      :last_paid_at,
      :timezone,
      :trial_banner_acknowledged_at
    ])
    |> validate_required([:name, :owner_id])
  end
end
