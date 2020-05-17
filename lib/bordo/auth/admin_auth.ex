defmodule Auth.AdminAuth do
  alias Auth.{Credentials}

  @moduledoc """
  This module is responsible for authenticating admin-users
  """

  @doc """
  Based on auth0 JWT, we need to get the claims and ensure the "admin:all" permission is present. If so,
  we need to sign a token and create a phoenix session.
  """
  def sign_in(username, password, session_uuid) do
    with {:ok, %{access_token: access_token}} <-
           Auth.sign_in(%Credentials{username: username, password: password}),
         {:ok, resource, %{"permissions" => [permissions]}} <-
           Auth.Guardian.resource_from_token(access_token) do
      case permissions do
        "admin:all" ->
          BordoWeb.Plug.Session.insert_session_token(session_uuid, resource.user_id)
          {:ok, "123"}

        [_] ->
          {:error, :forbidden}
      end
    else
      _ ->
        {:error, :forbidden}
    end
  end
end
