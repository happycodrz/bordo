defmodule Bordo.Brands.Brand do
  use Bordo.Schema
  import Ecto.Changeset

  schema "brands" do
    field :name, :string
    field :slug, :string
    belongs_to(:owner, Bordo.Users.User)
    has_many(:team_brands, Bordo.Brands.BrandTeam)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :owner_id, :slug])
    |> foreign_key_constraint(:owner_id)
    |> validate_required([:name, :owner_id, :slug])
  end
end
