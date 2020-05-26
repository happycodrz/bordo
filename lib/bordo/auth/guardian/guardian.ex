defmodule Auth.Guardian do
  @moduledoc """
  This is the main Guardian module used by the application to gain access to claims,
  identity, token, etc.
  Implements callback to properly integrate with Auth0.
  """
  use Guardian,
    otp_app: :bordo,
    permissions: %{default: ["read:all"], admin: ["admin:all"]}

  use Guardian.Permissions, encoding: Guardian.Permissions.BitwiseEncoding

  alias Auth.Identity
  alias Bordo.Repo
  alias Bordo.Users.User

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @doc """
  Based on the current_claims (jwt from auth0), this will build the current_resource.
  This can be very robust, and can essentially handle the entire state of the current_resource.
  """
  def resource_from_claims(%{"sub" => "auth0|" <> id}) do
    user = Repo.get_by!(User, auth0_id: id)
    {:ok, %Identity{id: id, user_id: user.id, team_id: user.team_id}}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Repo.get_by!(User, id: id)
    {:ok, %Identity{id: id, user_id: user.id, team_id: user.team_id}}
  end

  # def build_claims(claims, _resource, opts) do
  #   {:ok, encode_permissions_into_claims!(claims, Keyword.get(opts, :permissions))}
  # end
end
