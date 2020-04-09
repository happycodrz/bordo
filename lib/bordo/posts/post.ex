defmodule Bordo.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]
  import Ecto.Query, warn: false

  schema "posts" do
    field :title, :string
    field :uuid, :string
    field :scheduled_for, :utc_datetime
    field :brand_id, :id
    field :user_id, :id

    has_many :post_variants, Bordo.PostVariants.PostVariant
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for])
    |> cast_assoc(:post_variants)
    |> put_change(:uuid, generate_short_uuid())
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id])
  end

  def create_changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :brand_id, :user_id, :scheduled_for])
    |> cast_assoc(:post_variants, with: &Bordo.PostVariants.PostVariant.create_changeset/2)
    |> put_change(:uuid, generate_short_uuid())
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :brand_id, :user_id])
  end
end
