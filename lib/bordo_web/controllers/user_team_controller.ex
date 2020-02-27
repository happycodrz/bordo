defmodule BordoWeb.UserTeamController do
  use BordoWeb, :controller

  alias Bordo.Teams
  alias Bordo.Teams.UserTeam

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    user_teams = Teams.list_user_teams()
    render(conn, "index.json", user_teams: user_teams)
  end

  def create(conn, %{"user_team" => user_team_params}) do
    with {:ok, %UserTeam{} = user_team} <- Teams.create_user_team(user_team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_team_path(conn, :show, user_team))
      |> render("show.json", user_team: user_team)
    end
  end

  def show(conn, %{"id" => id}) do
    user_team = Teams.get_user_team!(id)
    render(conn, "show.json", user_team: user_team)
  end

  def update(conn, %{"id" => id, "user_team" => user_team_params}) do
    user_team = Teams.get_user_team!(id)

    with {:ok, %UserTeam{} = user_team} <- Teams.update_user_team(user_team, user_team_params) do
      render(conn, "show.json", user_team: user_team)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_team = Teams.get_user_team!(id)

    with {:ok, %UserTeam{}} <- Teams.delete_user_team(user_team) do
      send_resp(conn, :no_content, "")
    end
  end
end
