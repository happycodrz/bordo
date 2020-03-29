defmodule BordoWeb.GuardianSupport do
  import Auth.Guardian
  import Plug.Conn

  def authorize_request(conn, user) do
    {:ok, token, _} =
      encode_and_sign(%{user | id: "auth0|#{user.auth0_id}"}, %{}, token_type: :access)

    conn
    |> put_req_header("authorization", "bearer: " <> token)
  end
end
