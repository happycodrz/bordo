defmodule BordoWeb.Providers.TwitterController do
  use BordoWeb, :controller
  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    query = URI.encode_query(%{brand_id: brand_id})

    tokens =
      System.get_env("TWITTER_CALLBACK_URI")
      |> URI.parse()
      |> Map.merge(%{query: query})
      |> URI.to_string()
      |> ExTwitter.request_token()

    # Generate the url for "Sign-in with twitter".
    # For "3-legged authorization" use ExTwitter.authorize_url instead
    {:ok, authenticate_url} = ExTwitter.authenticate_url(tokens.oauth_token)
    json(conn, %{url: authenticate_url})
  end

  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier,
        "brand_id" => brand_id
      }) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    # Exchange for an access token
    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token) do
      brand = Bordo.Repo.get_by!(Brand, uuid: brand_id)
      IO.inspect(access_token, label: "ACCESS TOKEN")

      channel_params =
        Map.merge(
          %{
            "token" => access_token.oauth_token,
            "token_secret" => access_token.oauth_token_secret,
            "network" => "twitter"
          },
          %{"brand_id" => brand.id}
        )

      with {:ok, %Channel{} = channel} <- Channels.create_channel(channel_params) do
        conn
        |> put_status(:created)
        |> put_resp_header(
          "location",
          Routes.brand_channel_path(conn, :show, brand_id, channel)
        )
        |> put_view(BordoWeb.Brands.ChannelView)
        |> render("show.json", channel: channel)
      end
    else
      {:error, 401} ->
        json(conn, %{errors: %{detail: "auth failed"}})
    end
  end
end
