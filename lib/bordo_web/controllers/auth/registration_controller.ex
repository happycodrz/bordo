defmodule BordoWeb.RegistrationController do
  use BordoWeb, :controller

  alias Auth.Credentials
  alias Auth.Guardian
  alias Auth.Guardian.Plug
  alias Bordo.Users.Account
  # alias Bordo.Users
  alias Bordo.Users.User

  def index(conn, _params) do
    conn
    |> render("index.html",
      errors: nil,
      action: Routes.login_path(conn, :login),
      changeset: User.changeset(%User{}, %{})
    )
  end

  def register(conn, %{"user" => user_params}) do
    case Account.create_user_with_auth0(user_params) do
      {:ok, _user} ->
        Auth.sign_in(%Credentials{
          first_name: user_params["first_name"],
          last_name: user_params["last_name"],
          username: user_params["email"],
          password: Base.encode64(user_params["password"])
        })
        |> login_reply(conn)

      {:error, changeset} ->
        conn
        |> render("index.html",
          errors: "problem registering",
          action: Routes.registration_path(conn, :index),
          changeset: changeset
        )
    end
  end

  defp login_reply({:error, error}, conn) do
    conn
    |> render("index.html",
      errors: error,
      action: Routes.login_path(conn, :login)
    )
  end

  defp login_reply({:ok, %{access_token: token}, user}, conn) do
    case Guardian.decode_and_verify(token) do
      {:ok, %{"permissions" => permissions}} ->
        conn
        |> put_flash(:success, "Welcome back!")
        |> Plug.sign_in(user, %{pem: build_pem(permissions)})
        |> redirect(to: Routes.live_path(BordoWeb.Endpoint, BordoWeb.OnboardingLive.Index))

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
