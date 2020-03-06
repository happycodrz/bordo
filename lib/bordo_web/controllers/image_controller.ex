defmodule BordoWeb.ImageController do
  use BordoWeb, :controller

  alias Bordo.Media
  alias Bordo.Media.Image

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    images = Media.list_images()
    render(conn, "index.json", images: images)
  end

  def create(conn, %{"image" => image_params}) do
    with {:ok, %Image{} = image} <- Media.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.image_path(conn, :show, image))
      |> render("show.json", image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Media.get_image!(id)
    render(conn, "show.json", image: image)
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Media.get_image!(id)

    with {:ok, %Image{} = image} <- Media.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Media.get_image!(id)

    with {:ok, %Image{}} <- Media.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
