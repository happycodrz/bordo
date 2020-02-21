defmodule BordoWeb.AuthController do
  @moduledoc """
  This controller allows retrieving an access token from auth0 and returning it to the user
  providing username / password based login capability
  """
  use BordoWeb, :controller

  alias Auth
  alias Auth.{Credentials, TokenResult}

  require Logger

  # Handles common errors, mainly authorisation and unexpected errors
  action_fallback BordoWeb.FallbackController

  def create(conn, credentials) do
    _ = Logger.debug(fn -> "Login attempt with user: #{credentials["username"]}" end)

    with {:ok, credentials} <- Credentials.validate(credentials),
         {:ok, %TokenResult{} = result} <- Auth.sign_in(credentials) do
      conn
      |> put_status(:ok)
      |> render(:show, token_result: result)
    end
  end
end
