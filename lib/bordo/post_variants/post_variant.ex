defmodule Bordo.PostVariants.PostVariant do
  use Bordo.Schema
  import Ecto.Changeset

  alias Bordo.Channels

  @post_statuses ["draft", "published", "scheduled", "failed"]

  schema "post_variants" do
    field :content, :string
    field :status, :string
    field :external_id, :string
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    belongs_to :channel, Bordo.Channels.Channel
    belongs_to :post, Bordo.Posts.Post
    has_many :post_variant_media, Bordo.PostVariants.PostVariantMedia, on_replace: :delete

    many_to_many :media, Bordo.Media.Media, join_through: "post_variant_media"

    timestamps()
  end

  @doc false
  def changeset(post_variant, attrs) do
    post_variant
    |> Map.put(:temp_id, post_variant.temp_id || attrs["temp_id"])
    |> cast(attrs, [:channel_id, :status, :post_id, :content, :external_id])
    |> cast_assoc(:post_variant_media, default: [])
    |> validate_required([:channel_id, :status, :content])
    |> validate_inclusion(:status, @post_statuses)
  end

  @doc """
  Used to update the post-variant before it is published. Published posts cannot be changed, except to update the status.
  """
  def update_content_changeset(post_variant, attrs) do
    # Used to drop blank media_id, which comes from editing posts
    # This can probably be done a lot better
    # new_attrs =
    #   if Map.get(attrs, "post_variant_media") do
    #     pv_attrs =
    #       attrs
    #       |> Map.get("post_variant_media")
    #       |> Enum.filter(fn {_id, pvm} -> pvm["media_id"] != "" end)
    #       |> Enum.into(%{})

    #     attrs |> Map.replace!("post_variant_media", pv_attrs)
    #   else
    #     attrs
    #   end

    post_variant
    |> Map.put(:temp_id, post_variant.temp_id || attrs["temp_id"])
    |> cast(attrs, [:status, :post_id, :content])
    |> cast_assoc(:post_variant_media, default: [])
    |> validate_not_published(post_variant)
    |> put_change(:status, "scheduled")
    |> validate_required([:status, :content])
    |> validate_inclusion(:status, @post_statuses)
    |> maybe_mark_for_deletion()
  end

  def create_changeset(post_variant, attrs) do
    post_variant
    |> Map.put(:temp_id, post_variant.temp_id || attrs["temp_id"])
    |> cast(attrs, [:channel_id, :status, :post_id, :content])
    |> validate_twitter_length()
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

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  defp validate_twitter_length(changeset) do
    channel = Channels.get_channel!(get_field(changeset, :channel_id))

    if channel.network == "twitter" do
      content = get_field(changeset, :content) || ""
      if String.length(content) > 280 do
        add_error(changeset, :content, "Must be less than 280 characters")
      else
        changeset
      end
    else
      changeset
    end
  end
end
