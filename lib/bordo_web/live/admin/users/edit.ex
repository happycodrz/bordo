defmodule BordoWeb.Admin.UsersLive.Edit do
  use BordoWeb, :live_view
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Users

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{})}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    user = Users.get_user!(id)

    {:noreply,
     assign(socket, %{
       user: user,
       changeset: Users.change_user(user)
     })}
  end

  def render(assigns), do: BordoWeb.Admin.UserView.render("edit.html", assigns)

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> Users.change_user(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.update_user(socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully.")
         |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"user_id" => user_id}, socket) do
    user = Users.get_user!(user_id)
    {:ok, _user} = Users.delete_user(user)

    {:noreply,
     socket
     |> put_flash(:info, "User deleted successfully.")
     |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index))}
  end
end
