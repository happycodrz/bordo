defmodule BordoWeb.Brands.PostView do
  use BordoWeb, :view
  alias BordoWeb.Brands.PostView
  alias BordoWeb.PostVariantView

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
      user_id: post.user_id,
      scheduled_for: post.scheduled_for,
      slug: post.slug,
      post_variants:
        render_many(post.post_variants, PostVariantView, "post_variant.json", as: :post_variant)
    }
  end
end
