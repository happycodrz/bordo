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
      id: channel.id,
      token: channel.token,
      token_secret: channel.token_secret,
      network: channel.network,
      resource_id: channel.resource_id
    }
  end
end
