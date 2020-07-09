defmodule BordoWeb.Admin.UsersLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Users

  @impl true
  def render(assigns), do: BordoWeb.Admin.UserView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Users.subscribe()

    {:ok,
     assign(socket,
       users: Users.list_users(),
       title: "Users",
       action_module: BordoWeb.Admin.UsersLive.New,
       action_name: "Add New User"
     )}
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
