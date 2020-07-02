defmodule Bordo.Users.Account do
  @moduledoc """
  Context for user-related actions like auth0
  """

  alias Auth0Ex.Authentication
  alias Bordo.Users

  def create_user_with_auth0(attrs \\ %{}) do
    case Users.create_user(attrs) do
      {:ok, user} ->
        case Authentication.signup(
               System.get_env("AUTH0_CLIENT_ID"),
               user.email,
               attrs["password"],
               "Username-Password-Authentication"
             ) do
          {:ok, auth0_user} ->
            Users.update_user(user, %{auth0_id: auth0_user["_id"]})

          _ ->
            {:error, "Problem connecting user account"}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
