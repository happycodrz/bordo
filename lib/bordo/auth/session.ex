defmodule BordoWeb.Plug.Session do
  @moduledoc """
  This module is responsible for sessions: redirecting based on the user_id assign, inserting,
  validating, and signing the session-token.
  """
  import Plug.Conn, only: [get_session: 2, put_session: 3, halt: 1, assign: 3]
  import Phoenix.Controller, only: [redirect: 2]

  alias Bordo.Sessions
  alias Bordo.Sessions.Session

  def redirect_authorized(conn, _opts) do
    user_id = Map.get(conn.assigns, :current_identity)

    if is_nil(user_id) do
      conn
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(
        to: BordoWeb.Router.Helpers.admin_live_path(conn, BordoWeb.Admin.UsersLive.Index)
      )
      |> halt()
    end
  end

  def redirect_unauthorized(conn, _opts) do
    user_id = Map.get(conn.assigns, :user_id)

    if is_nil(user_id) do
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(to: BordoWeb.Router.Helpers.live_path(conn, BordoWeb.AuthLive.Login))
      |> halt()
    else
      conn
    end
  end

  def insert_session_token(key, user_id) do
    salt = signing_salt()
    token = Phoenix.Token.sign(BordoWeb.Endpoint, salt, user_id)
    Sessions.create_session(%{session_id: key, token: token})
  end

  def validate_session(conn, _opts) do
    case get_session(conn, :session_uuid) do
      nil ->
        conn
        |> put_session(:session_uuid, Ecto.UUID.generate())

      session_uuid ->
        conn
        |> validate_session_token(session_uuid)
    end
  end

  def validate_session_token(conn, session_uuid) do
    case Sessions.get_session(session_uuid) do
      %Session{token: token} ->
        case Phoenix.Token.verify(BordoWeb.Endpoint, signing_salt(), token, max_age: 2_419_200) do
          {:ok, user_id} ->
            assign(conn, :user_id, user_id)

          _ ->
            conn
        end

      _ ->
        conn
    end
  end

  def assign_current_admin(conn, _opts) do
    current_identity = Map.get(conn.assigns, :current_identity)

    if is_nil(current_identity) do
      conn
    else
      admin = Bordo.Users.get_user!(current_identity.user_id)
      assign(conn, :current_admin, admin)
    end
  end

  def assign_current_user(conn, _opts) do
    current_identity = Map.get(conn.assigns, :current_identity)

    if is_nil(current_identity) do
      conn
    else
      user = Bordo.Users.get_user!(current_identity.user_id)
      assign(conn, :current_user, user)
    end
  end

  def signing_salt do
    BordoWeb.Endpoint.config(:live_view)[:signing_salt] ||
      raise BordoWeb.AuthenticationError, message: "missing signing_salt"
  end
end

defmodule BordoWeb.AuthenticationError do
  defexception message: "authentication error unhandled"
end
