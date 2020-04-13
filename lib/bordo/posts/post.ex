defmodule Bordo.Posts.Post do
  use Bordo.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "posts" do
    field :title, :string
    field :scheduled_for, :utc_datetime
    field :slug, :string
    belongs_to(:brand, Bordo.Brands.Brand)
    belongs_to(:user, Bordo.Users.User)

    has_many :post_variants, Bordo.PostVariants.PostVariant
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for, :slug])
    |> cast_assoc(:post_variants)
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id, :slug])
  end

  def create_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for, :slug])
    |> cast_assoc(:post_variants, with: &Bordo.PostVariants.PostVariant.create_changeset/2)
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id, :slug])
  end
end
