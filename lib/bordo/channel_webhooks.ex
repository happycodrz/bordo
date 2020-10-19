defmodule Bordo.ChannelWebhooks do
  @moduledoc """
  Context for channel-specific webhooks
  """
  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Channels.Webhook

  @doc """
  Gets a channel_webhook.
  """
  def get_channel_webhook!(external_id: external_id) do
    query =
      from w in Webhook,
        where:
          w.external_id ==
            ^external_id

    query |> Repo.one()
  end

  @doc """
  Creates a channel_webhooks.

  ## Examples

      iex> create_channel_webhooks(%{field: value})
      {:ok, %ChannelWebhooks{}}

      iex> create_channel_webhooks(%{field: bad_value})
      {:error, ...}

  """
  def create_channel_webhook(attrs \\ %{}) do
    %Webhook{}
    |> Webhook.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a ChannelWebhooks.

  ## Examples

      iex> delete_channel_webhooks(channel_webhooks)
      {:ok, %ChannelWebhooks{}}

      iex> delete_channel_webhooks(channel_webhooks)
      {:error, ...}

  """
  def delete_channel_webhook(%Webhook{} = channel_webhook) do
    Repo.delete(channel_webhook)
  end
end
