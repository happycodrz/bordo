defmodule BordoWeb.TeamView do
  use BordoWeb, :view
  alias BordoWeb.TeamView

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      last_paid_at: team.last_paid_at,
      inserted_at: team.inserted_at
    }
  end
end
