defmodule BordoWeb.TeamControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Teams
  alias Bordo.Teams.Team
  alias Bordo.Users

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:team) do
    user = fixture(:user)
    {:ok, team} = Teams.create_team(@create_attrs |> Map.put(:owner_id, user.id))
    team
  end

  def fixture(:user) do
    {:ok, user} = Users.create_user(%{email: "xx", auth0_id: "1234"})
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      user = fixture(:user)

      conn =
        conn
        |> authorize_request(user)
        |> get(Routes.team_path(conn, :index))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create team" do
    test "renders team when data is valid", %{conn: conn} do
      user = fixture(:user)

      conn =
        conn
        |> authorize_request(user)
        |> post(Routes.team_path(conn, :create),
          team: @create_attrs |> Map.put(:owner_id, user.id)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = conn |> get(Routes.team_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = fixture(:user)

      conn =
        conn
        |> authorize_request(user)
        |> post(Routes.team_path(conn, :create), team: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team" do
    setup [:create_team]

    test "renders team when data is valid", %{conn: conn, team: %Team{id: id} = team} do
      user = Users.get_user!(team.owner_id)

      conn =
        conn
        |> authorize_request(user)
        |> put(Routes.team_path(conn, :update, team), team: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.team_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      user = Users.get_user!(team.owner_id)

      conn =
        conn
        |> authorize_request(user)
        |> put(Routes.team_path(conn, :update, team), team: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete team" do
    setup [:create_team]

    test "deletes chosen team", %{conn: conn, team: team} do
      user = Bordo.Users.get_user!(team.owner_id)

      conn =
        conn
        |> authorize_request(user)
        |> delete(Routes.team_path(conn, :delete, team))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.team_path(conn, :show, team))
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end
