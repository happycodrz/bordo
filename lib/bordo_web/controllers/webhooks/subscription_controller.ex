defmodule BordoWeb.Webhooks.SubscriptionController do
  @moduledoc """
  Used to manage subscriptions for zapier exclusively.
  """
  use BordoWeb, :controller

  alias Bordo.Channels
  alias Bordo.ChannelWebhooks

  @doc """
  Serves as example data when building zaps. This is an example-response of post-data sent to zapier.
  """
  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json([
      %{
        content: "Post content from Bordo!",
        media: [
          %{
            title: "Image title",
            url:
              "https://res.cloudinary.com/bordo/image/upload/v1601675411/lbrf8x0k172mi02916xy.jpg"
          }
        ]
      }
    ])
  end

  @doc """
  Creates a webhook subscription.
  """
  def create(conn, %{"id" => id, "hookUrl" => webhook_url}) do
    [api_key] = get_req_header(conn, "x-api-key")
    channel = Channels.get_channel!(token: api_key)

    string_id = Integer.to_string(id)

    case ChannelWebhooks.create_channel_webhook(%{
           channel_id: channel.id,
           external_id: string_id,
           webhook_url: webhook_url
         }) do
      {:ok, _channel} ->
        conn
        |> put_status(:created)
        |> json(%{status: "Subscription created"})

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{})
    end
  end

  @doc """
  Deletes a webhook subscription
  """
  def delete(conn, %{"id" => id}) do
    webhook = ChannelWebhooks.get_channel_webhook!(external_id: id)

    case ChannelWebhooks.delete_channel_webhook(webhook) do
      {:ok, _webhook} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "Subscription removed"})

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{})
    end
  end
end
