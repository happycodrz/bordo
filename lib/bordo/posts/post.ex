defmodule Bordo.Posts.Post do
  use Bordo.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias EctoSlugs.Bordo.Posts.NumberableSlug

  schema "posts" do
    field :title, :string
    field :scheduled_for, :utc_datetime
    field :slug, :integer
    belongs_to(:brand, Bordo.Brands.Brand)
    belongs_to(:user, Bordo.Users.User)

    has_many :post_variants, Bordo.PostVariants.PostVariant
    many_to_many :channels, Bordo.Channels.Channel, join_through: "post_variants"
    timestamps()
  end

  @doc """
  Default changeset, should not be unused in production application.
  """
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for])
    |> cast_assoc(:post_variants)
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id])
  end

  @doc false
  def update_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :scheduled_for])
    |> cast_assoc(:post_variants, with: &Bordo.PostVariants.PostVariant.update_content_changeset/2)
    |> validate_required([:title])
    |> validate_current_or_future_date(:scheduled_for)
  end

  @doc false
  def create_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for])
    |> cast_assoc(:post_variants,
      with: &Bordo.PostVariants.PostVariant.create_changeset/2,
      required: true,
      required_message: "Must add at least one channel"
    )
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id])
    |> validate_current_or_future_date(:scheduled_for)
    |> NumberableSlug.maybe_generate_slug()
    |> NumberableSlug.unique_constraint()
    |> slug_to_int()
  end

  defp slug_to_int(changeset) do
    slug = String.to_integer(changeset.changes.slug)

    put_change(changeset, :slug, slug)
  end

  def validate_current_or_future_date(%{changes: changes} = changeset, field) do
    if date = changes[field] do
      do_validate_current_or_future_date(changeset, field, date)
    else
      changeset
    end
  end

  defp do_validate_current_or_future_date(changeset, field, date) do
    if Timex.compare(date, Timex.now(), :hour) == -1 do
      changeset
      |> add_error(field, "You cannot schedule things in the past")
    else
      changeset
    end
  end
end
