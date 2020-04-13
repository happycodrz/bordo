defmodule BordoWeb.Brands.PostController do
  use BordoWeb, :controller

  alias Bordo.Posts
  alias Bordo.Posts.Post

  action_fallback BordoWeb.FallbackController

  def index(conn, %{"brand_id" => slug}) do
    posts = Posts.list_posts_for_brand(slug)
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => post_params, "brand_id" => brand_id}) do
    brand = Bordo.Brands.get_brand!(brand_id)
    post_params = post_params |> Map.merge(%{"user_id" => user_id(conn), "brand_id" => brand.id})

    with {:ok, %Post{} = post} <- Posts.create_and_schedule_post(post_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.brand_post_path(conn, :show, brand_id, post))
      |> render("show.json", post: post)
    else
      {:error, err} ->
        {:error, err}
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{} = post} <- Posts.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{}} <- Posts.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
