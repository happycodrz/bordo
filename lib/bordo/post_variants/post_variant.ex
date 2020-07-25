defmodule Bordo.PostVariants.PostVariant do
  use Bordo.Schema
  import Ecto.Changeset

  @post_statuses ["draft", "published", "scheduled", "failed"]

  schema "post_variants" do
    field :content, :string
    field :status, :string
    field :external_id, :string
    belongs_to :channel, Bordo.Channels.Channel
    belongs_to :post, Bordo.Posts.Post
    has_many :post_variant_media, Bordo.PostVariants.PostVariantMedia, on_replace: :delete

    many_to_many :media, Bordo.Media.Media, join_through: "post_variant_media"

    timestamps()
  end

  @doc false
  def changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :status, :post_id, :content, :external_id])
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  @doc """
  Used to update the post-variant before it is published. Published posts cannot be changed, except to update the status.
  """
  def update_content_changeset(post_variant, attrs) do
    # Used to drop blank media_id, which comes from editing posts
    # This can probably be done a lot better
    new_attrs =
      if Map.get(attrs, "post_variant_media") do
        pv_attrs =
          attrs
          |> Map.get("post_variant_media")
          |> Enum.filter(fn {_id, pvm} -> pvm["media_id"] != "" end)
          |> Enum.into(%{})

        attrs |> Map.replace!("post_variant_media", pv_attrs)
      else
        attrs
      end

    post_variant
    |> cast(new_attrs, [:status, :post_id, :content])
    |> cast_assoc(:post_variant_media, default: [])
    |> validate_not_published(post_variant)
    |> put_change(:status, "scheduled")
    |> validate_required([:status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  def create_changeset(post_variant, attrs) do
    post_variant
    |> cast(attrs, [:channel_id, :status, :post_id, :content])
    |> cast_assoc(:post_variant_media)
    |> put_change(:status, "scheduled")
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  def validate_not_published(changeset, post_variant) do
    case post_variant.status == "published" do
      true -> add_error(changeset, :status, "cannot update a published post")
      false -> changeset
    end
  end
end
