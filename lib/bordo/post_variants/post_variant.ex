defmodule Bordo.PostVariants.PostVariant do
  use Bordo.Schema
  import Ecto.Changeset

  @post_statuses ["draft", "published", "scheduled", "failed"]

  schema "post_variants" do
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
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  def create_changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :status, :post_id, :content])
    |> put_change(:status, "scheduled")
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end
end
