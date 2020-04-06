defmodule Bordo.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  @supported_networks ["twitter", "facebook"]

  schema "channels" do
    field :token, :string
    field :network, :string
    field :token_secret, :string
    field :uuid, :string

    belongs_to :brand, Bordo.Brands.Brand
    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:token, :token_secret, :network, :brand_id])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_inclusion(:network, @supported_networks,
      message: "must be one of #{supported_networks_error_msg()}"
    )
    |> validate_required([:token, :network, :brand_id])
  end

  defp supported_networks_error_msg do
    @supported_networks |> Enum.join(", ")
  end
end
