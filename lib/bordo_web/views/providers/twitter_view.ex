defmodule BordoWeb.Providers.TwitterView do
  use BordoWeb, :view
  alias BordoWeb.Providers.TwitterView

  def render("show.json", %{channel: channel}) do
    %{data: render_one(channel, TwitterView, "channel.json")}
  end

  def render("channel.json", %{twitter: twitter}) do
    %{
      uuid: twitter.uuid,
      auth_token: twitter.auth_token,
      refresh_token: twitter.refresh_token,
      network: twitter.network
    }
  end
end
