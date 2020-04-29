defmodule BordoWeb.Providers.TwitterController do
  use BordoWeb, :controller

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    configure_twitter()

    with {:ok, token} <- get_request_token(brand_id),
         {:ok, authenticate_url} <- get_authenticate_url(token) do
      json(conn, %{url: authenticate_url})
    else
      {:error, reason} ->
        conn
        |> put_status(422)
        |> json(%{errors: %{detail: reason}})

      _ ->
        conn
        |> put_status(422)
        |> json(%{errors: %{detail: "Auth error, check logs for details."}})
    end
  end

  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier,
        "brand_id" => brand_id
      }) do
    configure_twitter()

    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token),
         {:ok, %Channel{} = channel} <-
           Channels.create_channel(build_channel_params(access_token, brand_id)) do
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
        conn
        |> put_status(422)
        |> json(%{errors: %{detail: "auth failed"}})

      err ->
        conn
        |> put_status(422)
        |> json(%{errors: %{detail: err}})
    end
  end

  # Handling errors from extwitter request_token is difficult right now b/c no error tuple is returned
  # this could be refactored later to return the error tuple.
  defp get_request_token(brand_id) do
    query = URI.encode_query(%{brand_id: brand_id})

    try do
      tokens =
        System.get_env("TWITTER_CALLBACK_URI")
        |> URI.parse()
        |> Map.merge(%{query: query})
        |> URI.to_string()
        |> ExTwitter.request_token()

      {:ok, tokens}
    rescue
      MatchError ->
        {:error,
         "Error retrieving token, this could be due to configuration. Check logs for details."}
    end
  end

  defp get_authenticate_url(tokens) do
    tokens
    |> Map.get(:oauth_token)
    |> ExTwitter.authenticate_url()
  end

  defp build_channel_params(access_token, brand_id) do
    Map.merge(
      %{
        "token" => access_token.oauth_token,
        "token_secret" => access_token.oauth_token_secret,
        "network" => "twitter"
      },
      %{"brand_id" => brand_id}
    )
  end

  defp configure_twitter do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
      access_token_secret: System.get_env("TWITTER_ACCESS_TOKEN_SECRET")
    )
  end
end
