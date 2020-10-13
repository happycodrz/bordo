defmodule BordoWeb.WebhooksAuthPlug do
  @behaviour Plug
  import Plug.Conn, only: [send_resp: 3, halt: 1, get_req_header: 2]
  alias Bordo.Channels

  def init(config), do: config

  def call(%{request_path: "/stripe/webhooks"} = conn, _) do
    # signing_secret = Application.get_env(:stripity_stripe, :signing_secret)
    # {:ok, body, _} = Plug.Conn.read_body(conn)
    # [stripe_signature] = Plug.Conn.get_req_header(conn, "stripe-signature")
    # conn
  end

  def call(
        %{request_path: "/providers/zapier/check"} = conn,
        _
      ) do
    case get_req_header(conn, "x-api-key") do
      [api_key] ->
        channel = Channels.get_channel!(token: api_key)

        if zapier_api_key_valid?(channel, api_key) do
          conn
        else
          conn
          |> send_resp(403, "forbidden")
          |> halt()
        end

      _ ->
        conn
        |> send_resp(403, "forbidden")
        |> halt()
    end
  end

  def call(conn, _) do
    conn
  end

  defp zapier_api_key_valid?(_channel, api_key) when is_nil(api_key), do: false
  defp zapier_api_key_valid?(channel, _api_key) when is_nil(channel), do: false

  defp zapier_api_key_valid?(channel, api_key) do
    channel.token == api_key
  end
end
