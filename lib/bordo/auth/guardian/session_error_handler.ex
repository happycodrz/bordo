defmodule Auth.Guardian.SessionErrorHandler do
  @moduledoc """
  This is a fallback module for Guardian errors. If pipeline fails, we'll fallback here.
  """
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler

  @doc false
  def auth_error(conn, {:no_resource_found, _reason}, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: BordoWeb.Router.Helpers.login_path(conn, :index))
  end

  def auth_error(conn, {:unauthorized, :insufficient_permission}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, "insufficient_permission")
    |> halt()
  end
end
