defmodule BordoWeb.Brands.ChannelControllerTest do
  use BordoWeb.ConnCase

  @create_attrs %{
    token: "some token",
    network: "twitter",
    token_secret: "some token_secret"
  }
  @invalid_attrs %{token: nil, network: nil, token_secret: nil}

  setup %{conn: conn} do
    user = fixture(:user)
    brand = fixture(:brand, user: user)

    {:ok,
     conn: conn |> authorize_request(user) |> put_req_header("accept", "application/json"),
     brand: brand,
     user: user}
  end

  describe "index" do
    test "lists all channels", %{conn: conn, brand: brand} do
      conn = get(conn, Routes.brand_channel_path(conn, :index, brand))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create channel" do
    test "renders channel when data is valid", %{conn: conn, brand: brand} do
      conn = post(conn, Routes.brand_channel_path(conn, :create, brand), channel: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.brand_channel_path(conn, :show, brand, id))

      assert %{
               "id" => id,
               "token" => "some token",
               "network" => "twitter",
               "token_secret" => "some token_secret"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, brand: brand} do
      conn = post(conn, Routes.brand_channel_path(conn, :create, brand), channel: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete channel" do
    test "deletes chosen channel", %{conn: conn, brand: brand} do
      channel = fixture(:channel, brand: brand)
      conn = delete(conn, Routes.brand_channel_path(conn, :delete, brand, channel))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_channel_path(conn, :show, brand, channel))
      end
    end
  end
end
