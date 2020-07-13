defmodule Bordo.Brands.Brand do
  use Bordo.Schema
  import Ecto.Changeset

  alias EctoSlugs.Bordo.Brands.TitleSlug

  schema "brands" do
    field :name, :string
    field :slug, TitleSlug.Type
    field :image_url

    belongs_to :team, Bordo.Teams.Team

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :image_url, :team_id])
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name])
    |> validate_format(:name, ~r/\A[\w\_\-,\' ]+\z/, message: "must be alphanumeric, no emojis 🙈")
    |> unique_constraint(:name)
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint()
  end
end
