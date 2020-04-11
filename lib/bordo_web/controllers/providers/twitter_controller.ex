defmodule BordoWeb.Providers.TwitterController do
  use BordoWeb, :controller
  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    configure_twitter()

    {:ok, authenticate_url} =
      request_token(brand_id)
      |> Map.get(:oauth_token)
      |> ExTwitter.authenticate_url()

    json(conn, %{url: authenticate_url})
  end

  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier,
        "brand_id" => brand_id
      }) do
    configure_twitter()

    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token),
         brand = Bordo.Repo.get_by!(Brand, uuid: brand_id),
         {:ok, %Channel{} = channel} <-
           Channels.create_channel(build_channel_params(access_token, brand)) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.brand_channel_path(conn, :show, brand_id, channel)
      )
      |> put_view(BordoWeb.Brands.ChannelView)
      |> render("show.json", channel: channel)
    else
      {:error, 401} ->
        json(conn, %{errors: %{detail: "auth failed"}})

      err ->
        json(conn, %{errors: %{detail: err}})
    end
  end

  defp request_token(brand_id) do
    query = URI.encode_query(%{brand_id: brand_id})

    System.get_env("TWITTER_CALLBACK_URI")
    |> URI.parse()
    |> Map.merge(%{query: query})
    |> URI.to_string()
    |> ExTwitter.request_token()
  end

  defp build_channel_params(access_token, brand) do
    Map.merge(
      %{
        "token" => access_token.oauth_token,
        "token_secret" => access_token.oauth_token_secret,
        "network" => "twitter"
      },
      %{"brand_id" => brand.id}
    )
  end

  defp configure_twitter do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_ACCESS_TOKEN"),
      consumer_secret: System.get_env("TWITTER_ACCESS_TOKEN_SECRET")
    )
  end
end
