defmodule BordoWeb.BrandTeamController do
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Brands.BrandTeam

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    brand_teams = Brands.list_brand_teams()
    render(conn, "index.json", brand_teams: brand_teams)
  end

  def create(conn, %{"brand_team" => brand_team_params}) do
    with {:ok, %BrandTeam{} = brand_team} <- Brands.create_brand_team(brand_team_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.brand_team_path(conn, :show, brand_team))
      |> render("show.json", brand_team: brand_team)
    end
  end

  def show(conn, %{"id" => id}) do
    brand_team = Brands.get_brand_team!(id)
    render(conn, "show.json", brand_team: brand_team)
  end

  def update(conn, %{"id" => id, "brand_team" => brand_team_params}) do
    brand_team = Brands.get_brand_team!(id)

    with {:ok, %BrandTeam{} = brand_team} <- Brands.update_brand_team(brand_team, brand_team_params) do
      render(conn, "show.json", brand_team: brand_team)
    end
  end

  def delete(conn, %{"id" => id}) do
    brand_team = Brands.get_brand_team!(id)

    with {:ok, %BrandTeam{}} <- Brands.delete_brand_team(brand_team) do
      send_resp(conn, :no_content, "")
    end
  end
end
