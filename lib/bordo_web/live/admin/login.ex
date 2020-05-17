defmodule BordoWeb.Admin.AuthLive.Login do
  use BordoWeb, :live_view
  require Logger
  alias Auth
  alias Bordo.Users.User

  def mount(_params, session, socket) do
    changeset = Bordo.Users.User.changeset(%User{}, %{})

    {:ok,
     assign(socket, changeset: changeset, errors: false, session_uuid: session["session_uuid"])}
  end

  def render(assigns), do: BordoWeb.Admin.AuthView.render("login.html", assigns)

  def handle_event("login", %{"user" => login_params}, socket) do
    case Auth.AdminAuth.sign_in(
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
        changeset = Bordo.Users.User.changeset(%User{email: login_params["email"]}, %{})
        {:noreply, assign(socket, changeset: changeset, errors: true)}
    end
  end
end
