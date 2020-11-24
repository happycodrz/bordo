defmodule Bordo.Users.Account do
  @moduledoc """
  Context for user-related actions like auth0
  """

  alias Auth0Ex.Authentication
  alias Bordo.Users
  alias Ecto.Changeset

  def create_user_with_auth0(attrs \\ %{}) do
    case Users.create_user(attrs) do
      {:ok, user} ->
        case Authentication.signup(
               System.get_env("AUTH0_CLIENT_ID"),
               "chevinbrown+3@gmail.com",
               "password",
               "Username-Password-Authentication",
               %{
                 given_name: attrs["first_name"],
                 family_name: attrs["last_name"]
               }
             ) do
          {:ok, auth0_user} ->
            Users.update_user(user, %{auth0_id: auth0_user["_id"]})

          # If there is a problem with Auth0, we just need a generic error, there's nothing
          # we can do to handle it with 100% accuracy right now
          _ ->
            Users.change_user(user, attrs)
            |> Changeset.add_error(:email, "Problem connecting your email.")
            |> Changeset.apply_action(:insert)
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
