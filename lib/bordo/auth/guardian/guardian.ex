defmodule Auth.Guardian do
  @moduledoc """
  This is the main Guardian module used by the application to gain access to claims,
  identity, token, etc.
  Implements callback to properly integrate with Auth0.
  """
  use Guardian, otp_app: :bordo
  alias Auth.Identity

  # @impl Guardian
  @doc false
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  # @impl Guardian
  @doc false
  def resource_from_claims(%{"sub" => "auth0|" <> id}) do
    {:ok, %Identity{id: id}}
  end
end
