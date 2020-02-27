defmodule BordoWeb.UserTeamView do
  use BordoWeb, :view
  alias BordoWeb.UserTeamView

  def render("index.json", %{user_teams: user_teams}) do
    %{data: render_many(user_teams, UserTeamView, "user_team.json")}
  end

  def render("show.json", %{user_team: user_team}) do
    %{data: render_one(user_team, UserTeamView, "user_team.json")}
  end

  def render("user_team.json", %{user_team: user_team}) do
    %{id: user_team.id}
  end
end
