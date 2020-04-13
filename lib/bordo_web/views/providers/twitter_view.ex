defmodule BordoWeb.Providers.TwitterView do
  use BordoWeb, :view
  alias BordoWeb.Providers.TwitterView

  def render("show.json", %{channel: channel}) do
    %{data: render_one(channel, TwitterView, "channel.json")}
  end

  def render("channel.json", %{twitter: twitter}) do
    %{
      token: twitter.token,
      token_secret: twitter.token_secret,
      network: twitter.network
    }
  end
end
