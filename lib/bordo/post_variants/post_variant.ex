defmodule Bordo.PostVariants.PostVariant do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "post_variants" do
    field :uuid, :string
    field :title, :string
    belongs_to :channel, Bordo.Channels.Channel
    belongs_to :post, Bordo.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :post_id, :title])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:channel_id, :title])
  end
end
