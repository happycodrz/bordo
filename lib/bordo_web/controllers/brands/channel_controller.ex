defmodule BordoWeb.Brands.ChannelController do
  use BordoWeb, :controller

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    channels = Channels.list_channels()
    render(conn, "index.json", channels: channels)
  end

  def create(conn, %{"channel" => channel_params, "brand_id" => brand_uuid}) do
    brand = Bordo.Repo.get_by!(Bordo.Brands.Brand, uuid: brand_uuid)
    channel_params = Map.merge(channel_params, %{"brand_id" => brand.id})

    with {:ok, %Channel{} = channel} <- Channels.create_channel(channel_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.brand_channel_path(conn, :show, brand_uuid, channel))
      |> render("show.json", channel: channel)
    end
  end

  def show(conn, %{"id" => id}) do
    channel = Channels.get_channel!(id)
    render(conn, "show.json", channel: channel)
  end

  def update(conn, %{"id" => id, "channel" => channel_params}) do
    channel = Channels.get_channel!(id)

    with {:ok, %Channel{} = channel} <- Channels.update_channel(channel, channel_params) do
      render(conn, "show.json", channel: channel)
    end
  end

  def delete(conn, %{"id" => id}) do
    channel = Channels.get_channel!(id)

    with {:ok, %Channel{}} <- Channels.delete_channel(channel) do
      send_resp(conn, :no_content, "")
    end
  end
end
