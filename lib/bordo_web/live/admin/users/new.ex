defmodule BordoWeb.Admin.UsersLive.New do
  use BordoWeb, :live_view
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Users
  alias Bordo.Users.User

  def mount(_params, _session, socket) do
    changeset = Users.change_user(%User{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns), do: Phoenix.View.render(BordoWeb.Admin.UserView, "new.html", assigns)

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Users.change_user(user_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.create_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "user created")
         |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
