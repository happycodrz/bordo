defmodule BordoWeb.PostVariantView do
  use BordoWeb, :view
  alias BordoWeb.PostVariantView

  def render("index.json", %{post_variants: post_variants}) do
    %{data: render_many(post_variants, PostVariantView, "post_variant.json")}
  end

  def render("show.json", %{post_variant: post_variant}) do
    %{data: render_one(post_variant, PostVariantView, "post_variant.json")}
  end

  def render("post_variant.json", %{post_variant: post_variant}) do
    %{id: post_variant.id,
      uuid: post_variant.uuid}
  end
end
