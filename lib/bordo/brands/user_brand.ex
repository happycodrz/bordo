defmodule Bordo.Brands.UserBrand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_brands" do
    belongs_to :brand, :id
    belongs_to :user, :id

    timestamps()
  end

  @doc false
  def changeset(user_brand, attrs) do
    user_brand
    |> cast(attrs, [:brand_id, :user_id])
    |> validate_required([])
  end
end
