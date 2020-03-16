defmodule Bordo.Brands.UserBrand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_brands" do
    belongs_to :brand, Bordo.Brands.Brand
    belongs_to :user, Bordo.Users.User

    timestamps()
  end

  @doc false
  def changeset(user_brand, attrs) do
    user_brand
    |> cast(attrs, [:brand_id, :user_id])
    |> foreign_key_constraint(:brand_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required([])
  end
end
