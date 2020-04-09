defmodule BordoWeb.Brands.PostView do
  use BordoWeb, :view
  alias BordoWeb.Brands.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      brand_id: post.brand_id,
      user_id: post.user_id
    }
  end
end
