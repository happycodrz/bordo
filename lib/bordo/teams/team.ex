defmodule Bordo.Teams.Team do
  use Bordo.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :last_paid_at, :naive_datetime

    belongs_to :owner, Bordo.Users.User
    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :owner_id])
    |> validate_required([:name, :owner_id])
  end
end
