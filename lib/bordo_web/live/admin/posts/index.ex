defmodule BordoWeb.Admin.PostsLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Admin.Posts

  @impl true
  def render(assigns), do: BordoWeb.Admin.PostView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe()

    {:ok,
     assign(socket, posts: fetch_posts(%{}), show_modal: false, brands: Bordo.Brands.list_brands())}
  end

  @impl true
  def handle_params(%{"status" => status} = params, _uri, socket) do
    {:noreply, assign(socket, posts: fetch_posts(params), status: status)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, posts: fetch_posts(params), status: nil)}
  end

  @impl true
  def handle_info({Posts, [:post | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    posts = fetch_posts(%{})
    assign(socket, posts: posts)
  end

  @impl true
  def handle_event("modal-open", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("modal-close", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  defp fetch_posts(filters) do
    post_config = Posts.filter_options(:admin_posts)
    post_variant_config = Posts.filter_options(:admin_post_variants)

    with {:ok, post_filter} <- Filtrex.parse_params(post_config, Map.drop(filters, ~w(status))),
         {:ok, post_variant_filter} <-
           Filtrex.parse_params(post_variant_config, Map.drop(filters, ~w(brand_id))) do
      Posts.list_posts(post_filter, post_variant_filter)
    else
      {:error, error} ->
        error
    end
  end
end
