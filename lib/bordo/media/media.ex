defmodule Bordo.Media.Media do
  use Bordo.Schema
  import Ecto.Changeset

  @fields [
    :brand_id,
    :title,
    :public_id,
    :url,
    :thumbnail_url,
    :bytes,
    :width,
    :height,
    :resource_type
  ]

  @required_fields [
    :brand_id,
    :public_id,
    :url,
    :thumbnail_url,
    :bytes,
    :width,
    :height,
    :resource_type
  ]

  schema "media" do
    belongs_to(:brand, Bordo.Brands.Brand)
    field :title, :string
    field :public_id, :string, null: false
    field :url, :string, null: false
    field :thumbnail_url, :string, null: false
    field :bytes, :integer, null: false
    field :width, :integer, null: false
    field :height, :integer, null: false
    field :resource_type, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
