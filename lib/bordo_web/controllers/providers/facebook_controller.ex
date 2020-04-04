defmodule BordoWeb.Providers.FacebookController do
  use BordoWeb, :controller

  def auth(conn, _params) do
    query =
      URI.encode_query(%{
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI"),
        state: "2"
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

  def callback(conn, %{"code" => code}) do
    query =
      URI.encode_query(%{
        code: code,
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI"),
        client_secret: System.get_env("FACEBOOK_APP_SECRET")
      })

    json_response =
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

    {:ok, %{"access_token" => access_token}} = json_response

    json(conn, %{access_token: access_token})
  end
end
