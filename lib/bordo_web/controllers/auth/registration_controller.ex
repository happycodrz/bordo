defmodule BordoWeb.RegistrationController do
  use BordoWeb, :controller

  alias Bordo.Users.Account
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
        conn
        |> render("complete.html")

      {:error, changeset} ->
        conn
        |> render("index.html",
          errors: "problem registering",
          action: Routes.registration_path(conn, :index),
          changeset: changeset
        )
    end
  end
end
