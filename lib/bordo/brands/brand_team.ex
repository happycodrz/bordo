defmodule Bordo.Brands.BrandTeam do
  use Bordo.Schema
  import Ecto.Changeset

  schema "brand_teams" do
    belongs_to(:brand, Bordo.Brands.BrandTeam)
    belongs_to(:team, Bordo.Teams.Team)

    timestamps()
  end

  @doc false
  def changeset(brand_team, attrs) do
    brand_team
    |> cast(attrs, [:brand_id, :team_id])
    |> validate_required([:brand_id, :team_id])
  end
end
