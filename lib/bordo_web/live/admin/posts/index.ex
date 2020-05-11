defmodule BordoWeb.Admin.PostsLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Admin.Posts

  @impl true
  def render(assigns), do: BordoWeb.Admin.PostView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe()

    {:ok, assign(socket, posts: Posts.list_posts())}
  end

  @impl true
  def handle_info({Posts, [:post | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    posts = Posts.list_posts()
    assign(socket, posts: posts)
  end
end
