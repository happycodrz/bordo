defmodule BordoWeb.Admin.UsersLive.Edit do
  use BordoWeb, :live_view

  alias Auth0Ex.Authentication
  alias BordoWeb.Admin.UserView
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Users

  def mount(_params, _session, socket) do
    {:ok, assign(socket, auth0_loading: false)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    user = Users.get_user!(id)

    {:noreply,
     assign(socket, %{
       user: user,
       changeset: Users.change_user(user)
     })}
  end

  def render(assigns), do: UserView.render("edit.html", assigns)

  def handle_event("connect-auth0", %{"user_id" => user_id}, socket) do
    send(self(), {:connect_auth0, user_id})

    {:noreply, assign(socket, auth0_loading: true)}
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

  def handle_info({:connect_auth0, user_id}, socket) do
    length = 12
    password = :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)

    user = Users.get_user!(user_id)

    case Authentication.signup(
           System.get_env("AUTH0_CLIENT_ID"),
           user.email,
           password,
           "Username-Password-Authentication"
         ) do
      {:ok, auth0_user} ->
        {:ok, user} = Users.update_user(user, %{auth0_id: auth0_user["_id"]})

        {:noreply,
         socket
         |> assign(auth0_loading: false, user: user)
         |> put_flash(:success, "Auth0 Connected! Password: #{password}")}

      _ ->
        {:noreply,
         socket
         |> assign(auth0_loading: false)
         |> put_flash(:error, "Problem connecting Auth0!")}
    end
  end
end
