defmodule BordoWeb.Admin.AuthController do
  use BordoWeb, :controller
  import Plug.Conn, only: [get_session: 2, clear_session: 1, configure_session: 2]
  alias Bordo.Sessions

  def index(conn, _params) do
    conn
    |> delete_session_token(get_session(conn, :session_uuid))
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: Routes.live_path(conn, BordoWeb.AuthLive.Login))
  end

  def delete_session_token(conn, nil), do: conn

  def delete_session_token(conn, session_id) do
    session = Sessions.get_session(session_id)
    Sessions.delete_session(session)
    conn
  end
end
