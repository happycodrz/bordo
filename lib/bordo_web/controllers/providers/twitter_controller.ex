defmodule BordoWeb.Providers.TwitterController do
  use BordoWeb, :controller

  alias Bordo.Channels.Channel
  alias Bordo.Channels

  def auth(conn, _params) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    tokens = ExTwitter.request_token()

    # Generate the url for "Sign-in with twitter".
    # For "3-legged authorization" use ExTwitter.authorize_url instead
    {:ok, authenticate_url} = ExTwitter.authenticate_url(tokens.oauth_token)
    json(conn, authenticate_url)
  end

  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier,
        "brand_uuid" => brand_uuid
      }) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    # Exchange for an access token
    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token) do
      brand = Bordo.Repo.get_by!(Bordo.Brands.Brand, uuid: brand_uuid)

      channel_params =
        Map.merge(
          %{
            "auth_token" => access_token.oauth_token,
            "refresh_token" => access_token.oauth_token_secret,
            "network" => "twitter"
          },
          %{"brand_id" => brand.id}
        )

      with {:ok, %Channel{} = channel} <- Channels.create_channel(channel_params) do
        conn
        |> put_status(:created)
        |> put_resp_header(
          "location",
          Routes.brand_channel_path(conn, :show, brand_uuid, channel)
        )
        |> render("show.json", channel: channel)
      end
    else
      {:error, 401} ->
        conn
        |> json(%{errors: %{detail: "auth failed"}})
    end
  end
end
