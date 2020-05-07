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
    data = %{
      id: post_variant.id,
      content: post_variant.content,
      status: post_variant.status,
      external_id: post_variant.external_id,
      media:
        render_many(
          post_variant.media,
          BordoWeb.Brands.MediaView,
          "media.json",
          as: :media
        )
    }

    Enum.into(data, %{network: post_variant.channel.network})
  end
end
