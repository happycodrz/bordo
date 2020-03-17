defmodule Auth.Guardian do
  @moduledoc """
  This is the main Guardian module used by the application to gain access to claims,
  identity, token, etc.
  Implements callback to properly integrate with Auth0.
  """
  use Guardian, otp_app: :bordo
  alias Auth.Identity
  alias Bordo.Repo
  alias Bordo.Users.User

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @doc false
  def resource_from_claims(%{"sub" => "auth0|" <> id}) do
    # user_with_brands = Repo.get_by(User, auth0_id: id) |> Repo.preload([:brands])
    # TODO:
    # expand to cache user & current_brand?
    # expand %Identity to include better/more information as a session cache
    user = Repo.get_by(User, auth0_id: id)
    {:ok, %Identity{id: id, user_id: user.id, team_id: user.team_id}}
  end
end
