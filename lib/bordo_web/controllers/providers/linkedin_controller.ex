defmodule BordoWeb.Providers.LinkedinController do
  use BordoWeb, :controller

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    auth_url = Linkedin.auth_url(state: %{brand_id: brand_id})

    json(conn, %{url: auth_url})
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    IO.inspect("STILL HIT THE CALLBACK")
    %{"brand_id" => brand_id} = URI.decode_query(state)

    case Linkedin.access_token(code) do
      {:ok, %{"access_token" => access_token}} ->
        channel_params =
          Map.merge(
            %{
              "token" => access_token,
              "network" => "linkedin"
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

      {:ok, err} ->
        json(conn, %{
          error: %{detail: "Auth failed", message: err}
        })
    end
  end
end
