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
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:name, :icon_url])
  end

  def generate_short_uuid() do
    Ecto.UUID.generate() |> String.split("-") |> Enum.at(0)
  end
end
