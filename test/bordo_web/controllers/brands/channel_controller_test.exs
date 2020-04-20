defmodule BordoWeb.Brands.ChannelControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  @create_attrs %{
    token: "some token",
    network: "twitter",
    token_secret: "some token_secret"
  }
  @update_attrs %{
    token: "some updated token",
    network: "twitter",
    token_secret: "some updated token_secret"
  }
  @invalid_attrs %{token: nil, network: nil, token_secret: nil}

  def fixture(:channel, params) do
    {:ok, channel} = Channels.create_channel(@create_attrs |> Map.merge(params))
    channel
  end

  setup %{conn: conn} do
    {:ok, user} = Bordo.Users.create_user(%{email: "xx", auth0_id: "1234"})

    {:ok, brand} =
      Bordo.Brands.create_brand(%{name: "test brand", owner_id: user.id, slug: "test-brand"})

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
    setup [:create_channel]

    test "deletes chosen channel", %{conn: conn, channel: channel, brand: brand} do
      conn = delete(conn, Routes.brand_channel_path(conn, :delete, brand, channel))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_channel_path(conn, :show, brand, channel))
      end
    end
  end

  defp create_channel(%{brand: brand}) do
    channel = fixture(:channel, %{brand_id: brand.id})
    {:ok, channel: channel}
  end
end
