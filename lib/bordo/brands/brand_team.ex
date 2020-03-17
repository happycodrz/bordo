defmodule Bordo.Brands.BrandTeam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "brand_teams" do
    field :brand_id, :id
    field :team_id, :id

    timestamps()
  end

  @doc false
  def changeset(brand_team, attrs) do
    brand_team
    |> cast(attrs, [])
    |> validate_required([])
  end
end
