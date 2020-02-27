defmodule Bordo.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "teams" do
    field :name, :string
    field :uuid, :string
    field :owner_id, :id

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :owner_id])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:name, :owner_id])
  end
end
