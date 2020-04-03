defmodule BordoWeb.Brands.ChannelView do
  use BordoWeb, :view
  alias BordoWeb.Brands.ChannelView

  def render("index.json", %{channels: channels}) do
    %{data: render_many(channels, ChannelView, "channel.json")}
  end

  def render("show.json", %{channel: channel}) do
    %{data: render_one(channel, ChannelView, "channel.json")}
  end

  def render("channel.json", %{channel: channel}) do
    %{
      uuid: channel.uuid,
      auth_token: channel.auth_token,
      refresh_token: channel.refresh_token,
      network: channel.network
    }
  end
end
