defmodule Bordo.PostVariants.PostVariant do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  @post_statuses ["draft", "published", "scheduled", "failed"]

  schema "post_variants" do
    field :uuid, :string
    field :content, :string
    field :status, :string
    belongs_to :channel, Bordo.Channels.Channel
    belongs_to :post, Bordo.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :status, :post_id, :content])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  def create_changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :status, :post_id, :content])
    |> put_change(:uuid, generate_short_uuid())
    |> put_change(:status, "scheduled")
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end
end
