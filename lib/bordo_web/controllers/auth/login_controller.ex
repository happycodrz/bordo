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

  defp login_reply({:ok, %{access_token: token}, user}, conn) do
    case Auth.Guardian.decode_and_verify(token) do
      {:ok, %{"permissions" => permissions}} ->
        conn
        |> put_flash(:success, "Welcome back!")
        |> Auth.Guardian.Plug.sign_in(user, %{pem: build_pem(permissions)})
        |> redirect(to: "/")

      _ ->
        login_reply({:error, "Problem logging in"}, conn)
    end
  end

  defp build_pem(permissions) do
    if permissions == ["admin:all"] do
      %{admin: permissions}
    else
      %{default: ["read:all"]}
    end
  end
end
