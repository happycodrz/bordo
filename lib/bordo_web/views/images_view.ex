defmodule BordoWeb.ImagesView do
  use BordoWeb, :view
  alias BordoWeb.ImagesView

  def render("index.json", %{images: images}) do
    %{data: render_many(images, ImagesView, "images.json")}
  end

  def render("show.json", %{images: images}) do
    %{data: render_one(images, ImagesView, "images.json")}
  end

  def render("images.json", %{images: images}) do
    %{id: images.id,
      name: images.name,
      s3_path: images.s3_path,
      s3_object_name: images.s3_object_name}
  end
end
