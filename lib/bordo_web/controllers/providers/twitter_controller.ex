defmodule BordoWeb.Providers.TwitterController do
  @moduledoc """
  Handles oauth & channel-creation for twitter. It's important that each step handles the ExTwitter.configure(:process)
  individually, otherwise we risk getting user-info tied to the TWITTER_ACCESS_TOKEN, which will tie it to the app-owner,
  Kevin.
  """
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    configure_twitter()

    with {:ok, token} <- get_request_token(brand_id),
         {:ok, authenticate_url} <- get_authenticate_url(token) do
      redirect(conn, external: authenticate_url)
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

  @doc """
  Catches the oauth2 response from twitter and redirects to channels LV.
  This isn't ideal b/c this controller mixes json & html responses.
  """
  def callback(conn, %{
        "oauth_token" => oauth_token,
        "oauth_verifier" => oauth_verifier,
        "brand_id" => brand_id
      }) do
    ExTwitter.configure(:process, consumer_key: oauth_token, consumer_secret: oauth_verifier)

    with {:ok, access_token} <- ExTwitter.access_token(oauth_verifier, oauth_token),
         {:ok, %Channel{} = _channel} <-
           Channels.create_channel(build_channel_params(access_token, brand_id)) do
      brand = Brands.get_brand!(brand_id)

      conn
      |> redirect(to: Routes.live_path(conn, BordoWeb.SettingsLive, brand.slug))
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
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: access_token.oauth_token,
      access_token_secret: access_token.oauth_token_secret
    )

    user_info = Map.from_struct(ExTwitter.verify_credentials())

    Map.merge(
      %{
        "token" => access_token.oauth_token,
        "token_secret" => access_token.oauth_token_secret,
        "network" => "twitter",
        "resource_info" => user_info,
        "resource_id" => Integer.to_string(user_info.id)
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
