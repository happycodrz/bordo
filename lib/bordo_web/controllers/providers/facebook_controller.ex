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

    query =
      URI.encode_query(%{
        code: code,
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI"),
        client_secret: System.get_env("FACEBOOK_APP_SECRET")
      })

    with {:ok, %{"access_token" => access_token}} <- auth(query) do
      channel_params =
        Map.merge(
          %{
            "token" => access_token,
            "network" => "facebook"
          },
          %{"brand_id" => brand_id}
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

      json(conn, %{token: access_token})
    else
      {:ok,
       %{
         "error" => resp
       }} ->
        json(conn, %{
          error: %{detail: "Auth failed", message: resp["message"], type: resp["type"]}
        })
    end
  end

  defp auth(query) do
    %URI{
      host: "graph.facebook.com",
      path: "/v6.0/oauth/access_token",
      port: 443,
      query: query,
      scheme: "https"
    }
    |> URI.to_string()
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Jason.decode()
  end
end
