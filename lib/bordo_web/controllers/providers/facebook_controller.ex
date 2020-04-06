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

    with {:ok, %{"access_token" => access_token}} <- auth(query) do
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
