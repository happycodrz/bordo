defmodule BordoWeb.Brands.MediaView do
  use BordoWeb, :view
  alias BordoWeb.Brands.MediaView

  def render("index.json", %{media: media}) do
    %{data: render_many(media, MediaView, "media.json")}
  end

  def render("show.json", %{media: media}) do
    %{data: render_one(media, MediaView, "media.json")}
  end

  def render("media.json", %{media: media}) do
    %{
      id: media.id,
      title: media.title,
      public_id: media.public_id,
      url: media.url,
      thumbnail_url: media.thumbnail_url,
      bytes: media.bytes,
      width: media.width,
      height: media.height,
      resource_type: media.resource_type
    }
  end
end
