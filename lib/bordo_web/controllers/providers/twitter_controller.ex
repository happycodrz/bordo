defmodule BordoWeb.Providers.TwitterController do
  use BordoWeb, :controller

  def auth(conn, _params) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    tokens = ExTwitter.request_token()

    # Generate the url for "Sign-in with twitter".
    # For "3-legged authorization" use ExTwitter.authorize_url instead
    {:ok, authenticate_url} = ExTwitter.authenticate_url(tokens.oauth_token)
    json(conn, %{url: authenticate_url})
  end

  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier
      }) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")
    )

    # Exchange for an access token
    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token) do
      json(conn, %{
        "token" => access_token.oauth_token,
        "secret" => access_token.oauth_token_secret
      })
    else
      {:error, 401} ->
        json(conn, %{errors: %{detail: "auth failed"}})
    end
  end
end
