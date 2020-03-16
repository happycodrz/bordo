defmodule Bordo.Brands.Brand do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "brands" do
    field :name, :string
    field :owner_id, :id
    field :uuid, :string

    has_many(:user_brands, Bordo.Brands.UserBrand)
    many_to_many(:users, Bordo.Users.User, join_through: "user_brands")
    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :owner_id])
    |> put_change(:uuid, generate_short_uuid())
    |> foreign_key_constraint(:owner_id)
    |> validate_required([:name, :owner_id])
  end
end
