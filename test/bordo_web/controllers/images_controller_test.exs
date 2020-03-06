defmodule BordoWeb.ImagesControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Media
  alias Bordo.Media.Images

  @create_attrs %{
    name: "some name",
    s3_object_name: "some s3_object_name",
    s3_path: "some s3_path"
  }
  @update_attrs %{
    name: "some updated name",
    s3_object_name: "some updated s3_object_name",
    s3_path: "some updated s3_path"
  }
  @invalid_attrs %{name: nil, s3_object_name: nil, s3_path: nil}

  def fixture(:images) do
    {:ok, images} = Media.create_images(@create_attrs)
    images
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all images", %{conn: conn} do
      conn = get(conn, Routes.images_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create images" do
    test "renders images when data is valid", %{conn: conn} do
      conn = post(conn, Routes.images_path(conn, :create), images: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.images_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "s3_object_name" => "some s3_object_name",
               "s3_path" => "some s3_path"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.images_path(conn, :create), images: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update images" do
    setup [:create_images]

    test "renders images when data is valid", %{conn: conn, images: %Images{id: id} = images} do
      conn = put(conn, Routes.images_path(conn, :update, images), images: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.images_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name",
               "s3_object_name" => "some updated s3_object_name",
               "s3_path" => "some updated s3_path"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, images: images} do
      conn = put(conn, Routes.images_path(conn, :update, images), images: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete images" do
    setup [:create_images]

    test "deletes chosen images", %{conn: conn, images: images} do
      conn = delete(conn, Routes.images_path(conn, :delete, images))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.images_path(conn, :show, images))
      end
    end
  end

  defp create_images(_) do
    images = fixture(:images)
    {:ok, images: images}
  end
end
