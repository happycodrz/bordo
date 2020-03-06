defmodule Bordo.Media.Image do
  use Ecto.Schema
  import Ecto.Changeset

  schema "images" do
    field :name, :string
    field :s3_object_name, :string
    field :s3_path, :string

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:name, :s3_path, :s3_object_name])
    |> validate_required([:name, :s3_path, :s3_object_name])
  end
end
