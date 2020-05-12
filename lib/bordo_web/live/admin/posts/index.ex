defmodule BordoWeb.Admin.PostsLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Admin.Posts

  @impl true
  def render(assigns), do: BordoWeb.Admin.PostView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe()

    {:ok, assign(socket, posts: Posts.list_posts(), show_modal: false)}
  end

  @impl true
  def handle_info({Posts, [:post | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    posts = Posts.list_posts()
    assign(socket, posts: posts)
  end

  @impl true
  def handle_event("modal-open", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("modal-close", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end
end
