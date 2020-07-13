defmodule BordoWeb.BrandControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Brands
  alias Bordo.Brands.Brand

  @create_attrs %{
    icon_url: "some icon_url",
    name: "some name",
    slug: "some-name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{icon_url: nil, name: nil}

  setup %{conn: conn} do
    user = fixture(:user)
    {:ok, team} = Bordo.Teams.create_team(%{name: "Bordo!"})
    Bordo.Users.update_user(user, %{team_id: team.id})

    {:ok,
     conn: conn |> authorize_request(user) |> put_req_header("accept", "application/json"),
     user: user}
  end

  @tag :skip
  describe "index" do
    test "lists all brands", %{conn: conn} do
      conn = get(conn, Routes.brand_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "update brand" do
    setup [:create_brand]

    test "renders brand when data is valid", %{
      conn: conn,
      brand: %Brand{id: id} = brand
    } do
      conn = put(conn, Routes.brand_path(conn, :update, brand), brand: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.brand_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, brand: brand} do
      conn = put(conn, Routes.brand_path(conn, :update, brand), brand: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete brand" do
    setup [:create_brand]

    test "deletes chosen brand", %{conn: conn, brand: brand} do
      conn = delete(conn, Routes.brand_path(conn, :delete, brand))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_path(conn, :show, brand))
      end
    end
  end

  defp create_brand(%{}) do
    {:ok, brand} = Brands.create_brand(@create_attrs)
    {:ok, brand: brand}
  end
end
