defmodule BordoWeb.Live.AuthHelper do
  @moduledoc "Helpers to assist with loading the user from the session into the socket"
  @claims %{"typ" => "access"}
  @token_key "guardian_default_token"

  def load_user(%{@token_key => token}) do
    case Guardian.decode_and_verify(Auth.Guardian, token, @claims) do
      {:ok, claims} ->
        Auth.Guardian.resource_from_claims(claims)

      _ ->
        {:error, :not_authorized}
    end
  end

  def load_user(_), do: {:error, :not_authorized}
end
