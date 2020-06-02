defmodule BordoWeb.Admin.PostsLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Admin.Posts
  alias Bordo.Brands
  alias BordoWeb.Admin.PostView

  @impl true
  def render(assigns), do: PostView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Posts.subscribe()

    {:ok,
     assign(socket,
       posts: fetch_posts(%{}),
       show_modal: false,
       brands: [],
       brand_name: nil
     )}
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
    {:noreply, assign(socket, posts: fetch_posts(%{}))}
  end

  def handle_info({:select_brand, brand_name, status}, socket) do
    params =
      %{"name" => brand_name, "status" => status}
      |> Enum.reject(fn {_, v} -> v == nil || v == "" end)
      |> Enum.into(%{})

    {:noreply,
     push_patch(assign(socket, brand_name: brand_name),
       to: Routes.admin_live_path(socket, BordoWeb.Admin.PostsLive.Index, params),
       replace: true
     )}
  end

  @impl true
  def handle_event("modal-open", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("modal-close", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("suggest-brand", %{"brand_name" => brand_name}, socket) do
    {:noreply, assign(socket, brands: Brands.fuzzy_list_brands(brand_name), show_modal: false)}
  end

  def handle_event(
        "select-brand",
        %{"brand_name" => brand_name, "status" => status},
        socket
      ) do
    send(self(), {:select_brand, brand_name, status})
    {:noreply, socket}
  end

  defp fetch_posts(filters) do
    brand_config = Posts.filter_options(:admin_brands)
    post_variant_config = Posts.filter_options(:admin_post_variants)

    with {:ok, brand_filter} <- Filtrex.parse_params(brand_config, Map.drop(filters, ~w(status))),
         {:ok, post_variant_filter} <-
           Filtrex.parse_params(post_variant_config, Map.drop(filters, ~w(name))) do
      Posts.list_posts(brand_filter, post_variant_filter)
    else
      {:error, error} ->
        error
    end
  end
end
