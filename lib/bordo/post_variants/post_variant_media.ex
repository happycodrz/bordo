defmodule Bordo.PostVariants.PostVariantMedia do
  use Bordo.Schema

  import Ecto.Changeset

  schema "post_variant_media" do
    belongs_to :post_variant, Bordo.PostVariants.PostVariant
    belongs_to :media, Bordo.Media.Media

    timestamps()
  end

  @doc false
  def changeset(user_brand, attrs) do
    user_brand
    |> cast(attrs, [:post_variant_id, :media_id])
    |> foreign_key_constraint(:post_variant_id)
    |> foreign_key_constraint(:media_id)
    |> validate_required([:media_id])
  end
end
