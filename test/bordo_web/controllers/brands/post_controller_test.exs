defmodule BordoWeb.Brands.PostControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.Posts
  alias Bordo.Posts.Post

  @create_attrs %{
    status: "draft",
    title: "some title"
  }
  @update_attrs %{
    status: "published",
    title: "some updated title"
  }
  @invalid_attrs %{status: nil, title: nil}

  def fixture(:post, params) do
    {:ok, post} = Posts.create_post(@create_attrs |> Map.merge(params))
    post
  end

  setup %{conn: conn} do
    {:ok, user} = Bordo.Users.create_user(%{email: "xx", auth0_id: "1234"})
    {:ok, brand} = Bordo.Brands.create_brand(%{name: "test brand", owner_id: user.id})

    {:ok,
     conn: conn |> authorize_request(user) |> put_req_header("accept", "application/json"),
     brand: brand,
     user: user}
  end

  describe "index" do
    test "lists all posts", %{conn: conn, brand: brand} do
      conn = get(conn, Routes.brand_post_path(conn, :index, brand.uuid))

      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create post" do
    test "renders post when data is valid", %{conn: conn, brand: brand, user: user} do
      conn =
        post(conn, Routes.brand_post_path(conn, :create, brand),
          post: @create_attrs |> Map.merge(%{user_id: user.id, brand_id: brand.id})
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.brand_post_path(conn, :show, brand, id))

      assert %{
               "id" => id,
               "status" => "draft",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, brand: brand} do
      conn = post(conn, Routes.brand_post_path(conn, :create, brand), post: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update post" do
    setup [:create_post]

    test "renders post when data is valid", %{
      conn: conn,
      post: %Post{id: id} = post,
      brand: brand
    } do
      conn = put(conn, Routes.brand_post_path(conn, :update, brand, post), post: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.brand_post_path(conn, :show, brand, id))

      assert %{
               "id" => id,
               "status" => "published",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, brand: brand} do
      conn = put(conn, Routes.brand_post_path(conn, :update, brand, post), post: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, brand: brand, post: post} do
      conn = delete(conn, Routes.brand_post_path(conn, :delete, brand, post))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.brand_post_path(conn, :show, brand, post))
      end
    end
  end

  defp create_post(%{brand: brand, user: user}) do
    post = fixture(:post, %{brand_id: brand.id, user_id: user.id})
    {:ok, post: post}
  end
end
