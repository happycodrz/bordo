defmodule Bordo.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "posts" do
    field :status, :string
    field :title, :string
    field :uuid, :string
    field :brand_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :status])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:title, :status])
  end
end
