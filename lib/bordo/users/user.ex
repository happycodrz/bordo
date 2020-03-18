defmodule Bordo.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Bordo.Schema, only: [generate_short_uuid: 0]

  schema "users" do
    field :email, :string
    field :uuid, :string
    field :auth0_id, :string

    belongs_to :team, Bordo.Teams.Team
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :auth0_id, :team_id])
    |> put_change(:uuid, generate_short_uuid())
    |> validate_required([:email])
  end
end
