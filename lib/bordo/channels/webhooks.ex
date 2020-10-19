defmodule Bordo.Channels.Webhook do
  use Bordo.Schema
  import Ecto.Changeset

  schema "channel_webhooks" do
    field :external_id, :string
    field :webhook_url, :string

    belongs_to :channel, Bordo.Channels.Channel
    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [
      :channel_id,
      :external_id,
      :webhook_url
    ])
    |> validate_required([:channel_id, :external_id, :webhook_url])
  end
end
