defmodule Bordo.Brands.Brand do
  use Bordo.Schema
  import Ecto.Changeset

  alias EctoSlugs.Bordo.Brands.TitleSlug

  schema "brands" do
    field :name, :string
    field :slug, TitleSlug.Type
    belongs_to(:owner, Bordo.Users.User)
    has_many(:team_brands, Bordo.Brands.BrandTeam)

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :owner_id])
    |> foreign_key_constraint(:owner_id)
    |> validate_required([:name, :owner_id])
    |> unique_constraint(:name)
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint()
  end
end
