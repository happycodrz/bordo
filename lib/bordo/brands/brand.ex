defmodule Bordo.Brands.Brand do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "brands" do
    field :name, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, [:name])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:name])
  end
end
