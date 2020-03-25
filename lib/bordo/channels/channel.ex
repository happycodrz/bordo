defmodule Bordo.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "channels" do
    field :auth_token, :string
    field :network, :string
    field :refresh_token, :string
    field :uuid, :string
    field :brand_id, :id

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:auth_token, :refresh_token, :network, :brand_id])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:auth_token, :refresh_token, :network, :brand_id])
  end
end
