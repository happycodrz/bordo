defmodule Bordo.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]
  import Ecto.Query, warn: false

  @post_statuses ["draft", "published", "scheduled", "failed"]

  schema "posts" do
    field :status, :string
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
    |> cast(attrs, [:title, :status, :brand_id, :user_id, :scheduled_for])
    |> cast_assoc(:post_variants)
    |> put_change(:uuid, generate_short_uuid())
    |> foreign_key_constraint(:brand_id)
    |> validate_required([:title, :status, :brand_id, :user_id])
    |> validate_inclusion(:status, @post_statuses)
  end
end
