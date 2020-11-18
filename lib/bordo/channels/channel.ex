defmodule Bordo.Channels.Channel do
  use Bordo.Schema
  import Ecto.Changeset

  @supported_networks ["twitter", "facebook", "linkedin", "zapier"]

  schema "channels" do
    field :token, :string
    field :network, :string
    field :token_secret, :string
    field :resource_id, :string
    field :resource_info, :map
    field :image_url, :string
    field :label, :string
    field :needs_reauthentication, :string
    field :health_last_checked_at, :naive_datetime

    belongs_to :brand, Bordo.Brands.Brand
    has_many :post_variants, Bordo.PostVariants.PostVariant
    has_many :webhooks, Bordo.Channels.Webhook
    many_to_many :posts, Bordo.Posts.Post, join_through: "post_variants", on_replace: :delete
    timestamps()
  end

  def supported_networks do
    @supported_networks
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [
      :token,
      :token_secret,
      :network,
      :brand_id,
      :resource_id,
      :resource_info,
      :image_url,
      :label,
      :needs_reauthentication,
      :health_last_checked_at
    ])
    |> validate_inclusion(:network, @supported_networks,
      message: "must be one of #{supported_networks_error_msg()}"
    )
    |> validate_required([:token, :network, :brand_id])
  end

  defp supported_networks_error_msg do
    @supported_networks |> Enum.join(", ")
  end
end
