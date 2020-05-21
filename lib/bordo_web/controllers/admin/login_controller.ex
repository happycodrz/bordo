defmodule BordoWeb.LoginController do
  use BordoWeb, :controller

  alias Bordo.Users.User
  alias Auth.Credentials

  def index(conn, _params) do
    changeset = Bordo.Users.change_user(%User{})
    maybe_user = Auth.Guardian.Plug.current_resource(conn)

    message =
      if maybe_user != nil do
        "Someone is logged in"
      else
        "No one is logged in"
      end

    conn
    |> put_flash(:info, message)
    |> render("index.html",
      changeset: changeset,
      action: Routes.login_path(conn, :login),
      maybe_user: maybe_user,
      flash: nil
    )
  end

  def login(conn, %{"user" => %{"email" => username, "password" => password}}) do
    Auth.sign_in(%Credentials{username: username, password: Base.encode64(password)})
    |> login_reply(conn)
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: "/login")
  end

  defp login_reply({:ok, _token_resp, user}, conn) do
    conn
    |> put_flash(:success, "Welcome back!")
    |> Auth.Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end
end
