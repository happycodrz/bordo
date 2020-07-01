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
       show_slideover: false,
       brands: [],
       brand_name: nil,
       post: nil
     )}
  end

  def handle_params(%{"post_id" => post_id} = params, _uri, socket) do
    post = Posts.get_post!(post_id)
    filter_params = Map.drop(params, ~w(post_id))

    {:noreply,
     socket
     |> assign(
       status: nil,
       show_slideover: true,
       post: post,
       posts: fetch_posts(filter_params)
     )}
  end

  def handle_params(%{"status" => status} = params, _uri, socket) do
    {:noreply, assign(socket, posts: fetch_posts(params), status: status)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, posts: fetch_posts(params), status: nil)}
  end

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

  def handle_event("fetch-slideover", %{"post_id" => post_id}, socket) do
    {:noreply,
     socket
     |> assign(show_slideover: true)
     |> push_patch(
       to: Routes.admin_live_path(socket, BordoWeb.Admin.PostsLive.Index, post_id: post_id)
     )}
  end

  def handle_event("close-slideover", _params, socket) do
    # SO THE CSS ANIMATIONS HAVE TIME TO RUN
    :timer.sleep(300)

    {:noreply,
     socket
     |> assign(show_slideover: false)
     |> push_patch(to: Routes.admin_live_path(socket, BordoWeb.Admin.PostsLive.Index))}
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
