defmodule BordoWeb.Admin.UsersLive.New do
  use BordoWeb, :live_view
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Users
  alias Bordo.Users.Account
  alias Bordo.Users.User

  def mount(_params, _session, socket) do
    changeset = Users.change_user(%User{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns), do: render(BordoWeb.Admin.UserView, "new.html", assigns)

  def handle_event("save", %{"user" => user_params}, socket) do
    case Account.create_user_with_auth0(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User Created")
         |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
