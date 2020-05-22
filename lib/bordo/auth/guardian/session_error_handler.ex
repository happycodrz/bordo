defmodule Auth.Guardian.SessionErrorHandler do
  @moduledoc """
  This is a fallback module for Guardian errors. If pipeline fails, we'll fallback here.
  """

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler

  @doc false
  def auth_error(conn, {:no_resource_found, _reason}, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: BordoWeb.Router.Helpers.login_path(conn, :index))
  end
end
