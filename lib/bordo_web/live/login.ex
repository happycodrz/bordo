defmodule BordoWeb.AuthLive.Login do
  use BordoWeb, :live_view
  alias Auth.AdminAuth
  alias Bordo.Users.User
  alias BordoWeb.Admin.AuthView

  def mount(_params, session, socket) do
    changeset = User.changeset(%User{}, %{})

    {:ok,
     assign(socket, changeset: changeset, errors: false, session_uuid: session["session_uuid"])}
  end

  def render(assigns), do: AuthView.render("login.html", assigns)

  def handle_event("login", %{"user" => login_params}, socket) do
    case AdminAuth.sign_in(
           login_params["email"],
           Base.encode64(login_params["password"]),
           socket.assigns.session_uuid
         ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> redirect(
           to: Routes.admin_live_path(BordoWeb.Endpoint, BordoWeb.Admin.UsersLive.Index)
         )}

      {:error, _} ->
        changeset = User.changeset(%User{email: login_params["email"]}, %{})
        {:noreply, assign(socket, changeset: changeset, errors: true)}
    end
  end
end
