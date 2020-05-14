defmodule BordoWeb.Providers.FacebookController do
  use BordoWeb, :controller

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    query =
      URI.encode_query(%{
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI"),
        state: URI.encode_query(%{brand_id: brand_id})
      })

    auth_url =
      %URI{
        host: "facebook.com",
        path: "/v6.0/dialog/oauth",
        port: 443,
        query: query,
        scheme: "https"
      }
      |> URI.to_string()

    json(conn, %{url: auth_url})
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    %{"brand_id" => brand_id} = URI.decode_query(state)

    with {:ok, %{"access_token" => access_token}} <- get_access_token(code),
         {:ok, channel_params} <- build_channel_params(access_token, brand_id),
         {:ok, %Channel{} = channel} <- Channels.create_channel(channel_params),
         {:ok, %{"access_token" => access_token}} <- upgrade_access_token(access_token) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.brand_channel_path(conn, :show, brand_id, channel)
      )
      |> put_view(BordoWeb.Brands.ChannelView)
      |> render("show.json", channel: channel)

      json(conn, %{token: access_token})
    else
      {:error, error} ->
        json(conn, %{
          error: %{detail: "Auth failed", message: error["message"], type: error["type"]}
        })
    end
  end

  defp build_channel_params(access_token, brand_id) do
    {:ok,
     Map.merge(
       %{
         "token" => access_token,
         "network" => "facebook"
       },
       %{"brand_id" => brand_id}
     )}
  end

  defp get_access_token(code) do
    Facebook.access_token(
      System.get_env("FACEBOOK_APP_ID"),
      System.get_env("FACEBOOK_APP_SECRET"),
      System.get_env("FACEBOOK_REDIRECT_URI"),
      code
    )
  end

  @doc """
  Upgrades the access token to a long-lived token
  """
  defp upgrade_access_token(access_token) do
    Facebook.long_lived_access_token(
      System.get_env("FACEBOOK_APP_ID"),
      System.get_env("FACEBOOK_APP_SECRET"),
      access_token
    )
  end
end
