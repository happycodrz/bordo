defmodule BordoWeb.BrandTeamControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Brands
  alias Bordo.Brands.BrandTeam

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:brand_team) do
    {:ok, brand_team} = Brands.create_brand_team(@create_attrs)
    brand_team
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all brand_teams", %{conn: conn} do
      conn = get(conn, Routes.brand_team_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create brand_team" do
    test "renders brand_team when data is valid", %{conn: conn} do
      conn = post(conn, Routes.brand_team_path(conn, :create), brand_team: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.brand_team_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.brand_team_path(conn, :create), brand_team: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update brand_team" do
    setup [:create_brand_team]

    test "renders brand_team when data is valid", %{conn: conn, brand_team: %BrandTeam{id: id} = brand_team} do
      conn = put(conn, Routes.brand_team_path(conn, :update, brand_team), brand_team: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.brand_team_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, brand_team: brand_team} do
      conn = put(conn, Routes.brand_team_path(conn, :update, brand_team), brand_team: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete brand_team" do
    setup [:create_brand_team]

    test "deletes chosen brand_team", %{conn: conn, brand_team: brand_team} do
      conn = delete(conn, Routes.brand_team_path(conn, :delete, brand_team))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_team_path(conn, :show, brand_team))
      end
    end
  end

  defp create_brand_team(_) do
    brand_team = fixture(:brand_team)
    {:ok, brand_team: brand_team}
  end
end
