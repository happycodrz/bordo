defmodule Bordo.Users.User do
  use Bordo.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :auth0_id, :string
    field :first_name, :string
    field :last_name, :string
    field :image_url, :string
    field :password, :string, virtual: true

    belongs_to :team, Bordo.Teams.Team
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :auth0_id,
      :team_id,
      :image_url,
      :first_name,
      :last_name,
      :team_id,
      :password
    ])
    |> validate_email()
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :auth0_id,
      :team_id,
      :image_url,
      :first_name,
      :last_name,
      :team_id,
      :password
    ])
    |> validate_required(:first_name)
    |> validate_required(:last_name)
    |> validate_email()
    |> validate_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 254)
    |> unsafe_validate_unique(:email, Bordo.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 80)
  end
end
