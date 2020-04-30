defmodule Bordo.Channels.Channel do
  use Bordo.Schema
  import Ecto.Changeset

  @supported_networks ["twitter", "facebook", "linkedin"]

  schema "channels" do
    field :token, :string
    field :network, :string
    field :token_secret, :string
    field :resource_id, :string

    belongs_to :brand, Bordo.Brands.Brand
    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:token, :token_secret, :network, :brand_id, :resource_id])
    |> validate_inclusion(:network, @supported_networks,
      message: "must be one of #{supported_networks_error_msg()}"
    )
    |> validate_required([:token, :network, :brand_id])
  end

  defp supported_networks_error_msg do
    @supported_networks |> Enum.join(", ")
  end
end
