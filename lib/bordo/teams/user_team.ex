defmodule Bordo.Teams.UserTeam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_teams" do
    field :brand_id, :id
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
