defmodule BordoWeb.ImageView do
  use BordoWeb, :view
  alias BordoWeb.ImageView

  def render("index.json", %{images: images}) do
    %{data: render_many(images, ImageView, "image.json")}
  end

  def render("show.json", %{image: image}) do
    %{data: render_one(image, ImageView, "image.json")}
  end

  def render("image.json", %{image: image}) do
    %{id: image.id,
      name: image.name,
      s3_path: image.s3_path,
      s3_object_name: image.s3_object_name}
  end
end
