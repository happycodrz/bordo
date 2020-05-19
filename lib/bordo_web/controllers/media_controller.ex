defmodule BordoWeb.Brands.MediaController do
  use BordoWeb, :controller

  alias Bordo.Media, as: MediaResource
  alias Bordo.Media.Media

  action_fallback BordoWeb.FallbackController

  def index(conn, %{"brand_id" => brand_id}) do
    media = MediaResource.list_media(brand_id: brand_id)
    render(conn, "index.json", media: media)
  end

  def create(conn, %{"media" => media_params, "brand_id" => brand_id}) do
    with {:ok, %Media{} = media} <-
           MediaResource.create_media(media_params |> Map.merge(%{"brand_id" => brand_id})) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.brand_media_path(conn, :show, brand_id, media))
      |> render("show.json", media: media)
    end
  end

  def show(conn, %{"id" => id}) do
    media = MediaResource.get_media!(id)
    render(conn, "show.json", media: media)
  end

  def update(conn, %{"id" => id, "media" => media_params}) do
    media = MediaResource.get_media!(id)

    with {:ok, %Media{} = media} <- MediaResource.update_media(media, media_params) do
      render(conn, "show.json", media: media)
    end
  end

  def delete(conn, %{"id" => id}) do
    media = MediaResource.get_media!(id)

    with {:ok, %Media{}} <- MediaResource.delete_media(media) do
      send_resp(conn, :no_content, "")
    end
  end
end
