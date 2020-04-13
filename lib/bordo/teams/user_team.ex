defmodule Bordo.Teams.UserTeam do
  use Bordo.Schema
  import Ecto.Changeset

  schema "user_teams" do
    field :team_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_team, attrs) do
    user_team
    |> cast(attrs, [])
    |> validate_required([])
  end
end
