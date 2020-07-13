defmodule BordoWeb.Admin.UsersLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Users
  alias BordoWeb.Admin.UserView

  @impl true
  def render(assigns), do: UserView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Users.subscribe()

    {:ok,
     assign(socket,
       users: Users.list_users(),
       title: "Users",
       action_module: BordoWeb.Admin.UsersLive.New,
       action_name: "Add New User",
       show_slideover: false
     )}
  end

  @impl true
  def handle_params(%{"user_id" => user_id}, _uri, socket) do
    user = Users.get_user!(user_id)

    {:noreply,
     socket
     |> assign(
       status: nil,
       show_slideover: true,
       user: user
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, users: Users.list_users())}
  end

  @impl true
  def handle_event("fetch-slideover", %{"user_id" => user_id}, socket) do
    {:noreply,
     socket
     |> assign(show_slideover: true)
     |> push_patch(
       to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index, user_id: user_id)
     )}
  end

  def handle_event("close-slideover", _params, socket) do
    # SO THE CSS ANIMATIONS HAVE TIME TO RUN
    :timer.sleep(300)

    {:noreply,
     socket
     |> assign(show_slideover: false)
     |> push_patch(to: Routes.admin_live_path(socket, BordoWeb.Admin.UsersLive.Index))}
  end

  @impl true
  def handle_info({Users, [:user | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    users = Users.list_users()
    assign(socket, users: users)
  end
end
