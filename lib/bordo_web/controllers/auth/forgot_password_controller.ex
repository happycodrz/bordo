defmodule BordoWeb.ForgotPasswordController do
  use BordoWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html",
      requested: false,
      action: Routes.login_path(conn, :login)
    )
  end

  def reset(conn, %{"user" => user_params}) do
    request_password_reset(user_params["email"])

    conn
    |> render("index.html", requested: true, action: Routes.forgot_password_path(conn, :index))
  end

  defp request_password_reset(email) do
    HTTPoison.post(
      "https://bordo.auth0.com/dbconnections/change_password",
      %{
        "client_id" => System.get_env("AUTH0_CLIENT_ID"),
        "email" => email,
        "connection" => "Username-Password-Authentication"
      }
      |> Jason.encode!(),
      "Content-Type": "application/json"
    )
  end
end
