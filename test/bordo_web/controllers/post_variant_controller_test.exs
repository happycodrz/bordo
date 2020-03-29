defmodule BordoWeb.PostVariantControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  @create_attrs %{
    uuid: "some uuid"
  }
  @update_attrs %{
    uuid: "some updated uuid"
  }
  @invalid_attrs %{uuid: nil}

  def fixture(:post_variant) do
    {:ok, post_variant} = PostVariants.create_post_variant(@create_attrs)
    post_variant
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all post_variants", %{conn: conn} do
      conn = get(conn, Routes.post_variant_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create post_variant" do
    test "renders post_variant when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_variant_path(conn, :create), post_variant: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.post_variant_path(conn, :show, id))

      assert %{
               "id" => id,
               "uuid" => "some uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.post_variant_path(conn, :create), post_variant: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update post_variant" do
    setup [:create_post_variant]

    test "renders post_variant when data is valid", %{conn: conn, post_variant: %PostVariant{id: id} = post_variant} do
      conn = put(conn, Routes.post_variant_path(conn, :update, post_variant), post_variant: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.post_variant_path(conn, :show, id))

      assert %{
               "id" => id,
               "uuid" => "some updated uuid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, post_variant: post_variant} do
      conn = put(conn, Routes.post_variant_path(conn, :update, post_variant), post_variant: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete post_variant" do
    setup [:create_post_variant]

    test "deletes chosen post_variant", %{conn: conn, post_variant: post_variant} do
      conn = delete(conn, Routes.post_variant_path(conn, :delete, post_variant))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.post_variant_path(conn, :show, post_variant))
      end
    end
  end

  defp create_post_variant(_) do
    post_variant = fixture(:post_variant)
    {:ok, post_variant: post_variant}
  end
end
