defmodule BordoWeb.MediaControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Media, as: MediaResource

  @create_attrs %{
    title: "some title",
    public_id: Ecto.UUID.generate(),
    url: "http://bor.do/media/123.png",
    thumbnail_url: "http://bor.do/media/123.png",
    bytes: 1024,
    width: 7,
    height: 7,
    resource_type: "image"
  }
  @invalid_attrs %{}

  setup %{conn: conn} do
    user = fixture(:user)

    {:ok, brand} = Bordo.Brands.create_brand(%{name: "test brand", slug: "test-brand"})

    {:ok,
     brand: brand,
     conn: conn |> authorize_request(user) |> put_req_header("accept", "application/json")}
  end

  describe "index" do
    test "lists all medias", %{conn: conn, brand: brand} do
      conn = get(conn, Routes.brand_media_path(conn, :index, brand))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create media" do
    test "renders media when data is valid", %{conn: conn, brand: brand} do
      conn =
        post(conn, Routes.brand_media_path(conn, :create, brand),
          media: @create_attrs |> Map.merge(%{brand_id: brand.id})
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.brand_media_path(conn, :show, brand, id))

      assert %{
               "id" => id,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, brand: brand} do
      conn = post(conn, Routes.brand_media_path(conn, :create, brand), media: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete media" do
    setup [:create_media]

    test "deletes chosen media", %{conn: conn, brand: brand, media: media} do
      conn = delete(conn, Routes.brand_media_path(conn, :delete, brand, media))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_media_path(conn, :show, brand, media))
      end
    end
  end

  defp create_media(%{brand: brand}) do
    {:ok, media} = MediaResource.create_media(@create_attrs |> Map.merge(%{brand_id: brand.id}))
    {:ok, media: media}
  end
end
