defmodule BordoWeb.LoginController do
  use BordoWeb, :controller

  alias Auth.Credentials

  def index(conn, _params) do
    conn
    |> render("index.html",
      errors: nil,
      action: Routes.login_path(conn, :login)
    )
  end

  def login(conn, %{"user" => %{"email" => username, "password" => password}}) do
    Auth.sign_in(%Credentials{username: username, password: Base.encode64(password)})
    |> login_reply(conn)
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> render("index.html",
      errors: error,
      action: Routes.login_path(conn, :login)
    )
  end

  defp login_reply({:ok, _token_resp, user}, conn) do
    conn
    |> put_flash(:success, "Welcome back!")
    |> Auth.Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end
end
