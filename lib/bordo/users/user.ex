defmodule Bordo.Users.User do
  use Bordo.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :auth0_id, :string
    field :first_name, :string
    field :last_name, :string
    field :image_url, :string

    belongs_to :team, Bordo.Teams.Team
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :auth0_id, :team_id, :image_url])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
