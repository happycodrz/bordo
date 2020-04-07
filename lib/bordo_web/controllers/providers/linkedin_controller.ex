defmodule BordoWeb.Providers.LinkedinController do
  use BordoWeb, :controller

  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  @redirect_uri System.get_env("LINKEDIN_REDIRECT_URI")

  def auth(conn, %{"brand_id" => brand_id}) do
    query =
      URI.encode_query(%{
        state: URI.encode_query(%{brand_id: brand_id}),
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: @redirect_uri,
        response_type: "code",
        scope: "w_member_social"
      })

    auth_url =
      %URI{
        host: "www.linkedin.com",
        path: "/oauth/v2/authorization",
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
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: @redirect_uri,
        client_secret: System.get_env("LINKEDIN_CLIENT_SECRET"),
        grant_type: "authorization_code"
      })

    with {:ok, %{"access_token" => access_token}} <- auth(query) do
      brand = Bordo.Repo.get_by!(Brand, uuid: brand_id)

      channel_params =
        Map.merge(
          %{
            "token" => access_token,
            "network" => "linkedin"
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

      json(conn, %{token: access_token})
    else
      {:ok, err} ->
        json(conn, %{
          error: %{detail: "Auth failed", message: err}
        })
    end
  end

  defp auth(query) do
    uri = %URI{
      host: "www.linkedin.com",
      path: "/oauth/v2/accessToken",
      port: 443,
      query: query,
      scheme: "https"
    }

    with {:ok, response} <- get_token(uri) do
      response
      |> Map.get(:body)
      |> Jason.decode()
    end
  end

  defp get_token(uri) do
    uri
    |> URI.to_string()
    |> HTTPoison.post("", [{"Content-Type", "x-www-form-urlencoded"}])
  end
end
