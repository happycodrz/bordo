defmodule Bordo.Brands.Brand do
  use Ecto.Schema
  import Ecto.Changeset

  schema "brands" do
    field :icon_url, :string
    field :name, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name, :icon_url])
    |> validate_required([:name, :icon_url])
  end
end
