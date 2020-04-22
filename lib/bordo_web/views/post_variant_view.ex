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
      external_id: post_variant.external_id
    }

    if Ecto.assoc_loaded?(post_variant.channel) do
      Enum.into(data, %{channel_name: post_variant.channel.network})
    end
  end
end
