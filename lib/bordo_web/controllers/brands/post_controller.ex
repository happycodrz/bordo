defmodule BordoWeb.Brands.PostController do
  use BordoWeb, :controller

  alias Bordo.Posts
  alias Bordo.Posts.Post

  action_fallback BordoWeb.FallbackController

  def index(conn, %{"brand_id" => brand_id} = params) do
    # remove keys that are not filtered against
    filter_params = Map.drop(params, ~w(brand_id))

    config = Bordo.Posts.filter_options(:brand_index)

    case Filtrex.parse_params(config, filter_params) do
      {:ok, filter} ->
        posts = Posts.list_posts(brand_id, filter)
        render(conn, "index.json", posts: posts)

      {:error, error} ->
        conn
        |> json(%{errors: %{detail: error}})
    end
  end

  def create(conn, %{"post" => post_params, "brand_id" => brand_id}) do
    post_params = post_params |> Map.merge(%{"user_id" => user_id(conn), "brand_id" => brand_id})

    case Posts.create_and_schedule_post(post_params) do
      {:ok, %Post{} = post} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.brand_post_path(conn, :show, brand_id, post))
        |> render("show.json", post: post)

      {:error, err} ->
        {:error, err}
    end
  end

  def show(conn, %{"id" => id, "brand_id" => brand_id}) do
    post = Posts.get_brand_post!(id, brand_id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params, "brand_id" => brand_id}) do
    post = Posts.get_brand_post!(id, brand_id)

    with {:ok, %Post{} = post} <- Posts.update_and_schedule_post(post, post_params) do
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
