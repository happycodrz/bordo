defmodule Auth.Guardian.SessionPipeline do
  @moduledoc """
  Configures a set of plugs to be used with Guardian based authentication / authorisation
  """
  use Guardian.Plug.Pipeline,
    otp_app: :bordo,
    error_handler: Auth.Guardian.SessionErrorHandler,
    module: Auth.Guardian

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource

  # Add :current_identity to the connection
  plug :assign_current_identity

  defp assign_current_identity(conn, _) do
    conn
    |> assign(:current_identity, Guardian.Plug.current_resource(conn))
  end
end
