defmodule BordoWeb.BrandTeamView do
  use BordoWeb, :view
  alias BordoWeb.BrandTeamView

  def render("index.json", %{brand_teams: brand_teams}) do
    %{data: render_many(brand_teams, BrandTeamView, "brand_team.json")}
  end

  def render("show.json", %{brand_team: brand_team}) do
    %{data: render_one(brand_team, BrandTeamView, "brand_team.json")}
  end

  def render("brand_team.json", %{brand_team: brand_team}) do
    %{id: brand_team.id}
  end
end
