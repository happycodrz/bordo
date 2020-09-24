defmodule BordoWeb.MediaLive do
  use BordoWeb, :client_live_view
  alias Bordo.{Brands, Media}

  def render(assigns) do
    ~L"""
    <div class="m-8 min-h-screen flex flex-col" id="edit-media">
      <div class="flex-1 mb-4">
        <%= search_menu(assigns) %>
        <%= if Enum.empty?(@medias) do %>
          <%= if @search == "" do %>
            <div class="bg-gray-50 overflow-hidden rounded-lg mt-8">
              <div class="px-4 py-5 sm:p-6">
                Use the dropdown menu to add media.
              </div>
            </div>
          <% else %>
            <div class="bg-gray-50 overflow-hidden rounded-lg mt-8">
              <div class="px-4 py-5 sm:p-6">
                No results.
              </div>
            </div>
          <% end %>
        <% else %>
          <ul class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3 mt-3 flex-grow flex-1">
            <%= for media <- @medias do %>
              <%= media_card(media) %>
            <% end %>
          </ul>
        </div>
        <%= live_component(@socket, BordoWeb.Components.Pagination, id: "media-pagination", total_pages: @total_pages, page_number: @page_number, target: "#edit-media") %>
      <% end %>
      <%= if @show_slideover do %>
        <%= live_component(@socket,
          BordoWeb.Components.EmptySlideOver,
          id:  "edit-media",
          title: "New Post",
          with_overlay: true,
          size: "large",
          target: "#edit-media") do %>
          <%= slideover_body( [media: @media, changeset: @changeset]) %>
        <% end %>
      <% end %>
      <%= live_component(@socket,
        BordoWeb.Components.Modal,
        id: "unsplash-modal",
        title: "Add Unsplash Image",
        state: "CLOSED",
        size: "large"
        ) do %>
        <%= live_component(@socket, BordoWeb.Media.UnsplashSearch, id: "unsplash-search", unsplash_search: "", unsplash_results: [], page: 1, active_brand: @active_brand, loading: false) %>
      <% end %>
      <div id="CanvaHook" phx-hook="Canva"></div>
    </div>
    """
  end

  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)

    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Media.list_media(active_brand.id)

    {:ok,
     assign(socket,
       active_brand: active_brand,
       medias: entries,
       nav_item: "media",
       show_slideover: false,
       search: "",
       page_number: page_number || 0,
       page_size: page_size || 0,
       total_entries: total_entries || 0,
       total_pages: total_pages || 0
     )}
  end

  def handle_event("save", %{"media" => media_params}, socket) do
    case Media.update_media(socket.assigns.media, media_params) do
      {:ok, media} ->
        {:noreply,
         socket
         |> put_flash(:success, "Updated #{media.title}")
         |> push_redirect(
           to: Routes.live_path(socket, BordoWeb.MediaLive, socket.assigns.active_brand.slug)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("search", %{"search" => search}, socket) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Media.list_media(socket.assigns.active_brand.id, search: search)

    {:noreply,
     socket
     |> assign(
       search: search,
       medias: entries,
       page_number: page_number || 0,
       page_size: page_size || 0,
       total_entries: total_entries || 0,
       total_pages: total_pages || 0
     )}
  end

  def handle_event("delete", _data, socket) do
    media = socket.assigns.media

    case Media.delete_media(media) do
      {:ok, _media} ->
        {:noreply,
         socket
         |> put_flash(:success, "Deleted #{media.title}")
         |> push_redirect(
           to: Routes.live_path(socket, BordoWeb.MediaLive, socket.assigns.active_brand.slug)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "There was a problem removing #{media.title}")
         |> assign(changeset: changeset)}
    end
  end

  def handle_event("open-slideover", %{"media_id" => media_id}, socket) do
    media = Media.get_media!(media_id)

    {:noreply,
     socket
     |> assign(:show_slideover, true)
     |> assign(:media, media)
     |> assign(:changeset, Media.change_media(media))}
  end

  def handle_event("close-slideover", _data, socket),
    do: {:noreply, assign(socket, :show_slideover, false)}

  def handle_event("nav", %{"page" => page}, socket) do
    {:noreply,
     push_redirect(socket,
       to:
         Routes.live_path(socket, BordoWeb.MediaLive, socket.assigns.active_brand.slug, %{
           page: page
         })
     )}
  end

  def handle_event("upload-success", params, socket) do
    {:ok, media} =
      Media.create_media(%{
        "title" => params["title"],
        "public_id" => params["public_id"],
        "url" => params["url"],
        "thumbnail_url" => params["thumbnail_url"],
        "bytes" => params["bytes"],
        "width" => params["width"],
        "height" => params["height"],
        "resource_type" => "image",
        "brand_id" => socket.assigns.active_brand.id
      })

    {:noreply,
     socket
     |> put_flash(:success, "Uploaded #{params["title"]}")
     |> assign(:medias, Enum.concat(socket.assigns.medias, [media]))}
  end

  def handle_event("canva-upload", %{"url" => url}, socket) do
    send(self(), {:upload, url})
    {:noreply, socket}
  end

  def handle_event("open-canva", _data, socket) do
    {:noreply, push_event(socket, "open", %{})}
  end

  def handle_info({:upload, url}, socket) do
    {:ok, result} = Cloudex.upload([url], %{eager: "c_fit,w_400,h_400"})

    {:ok, media} =
      Media.create_media(%{
        "title" => result.original_filename,
        "public_id" => result.public_id,
        "url" => result.url,
        "thumbnail_url" => result.eager |> Enum.at(0) |> Map.get("url"),
        "bytes" => result.bytes,
        "width" => result.width,
        "height" => result.height,
        "resource_type" => "image",
        "brand_id" => socket.assigns.active_brand.id
      })

    send_update(BordoWeb.Media.UnsplashSearch, %{id: "unsplash-search", loading: false})

    {:noreply,
     socket
     |> put_flash(:success, "Uploaded #{result.original_filename}")
     |> assign(medias: socket.assigns.medias |> Enum.concat([media]))}
  end

  def handle_params(%{"page" => page}, _, socket) do
    assigns = get_and_assign_page(socket.assigns.active_brand.id, page)
    {:noreply, assign(socket, assigns)}
  end

  def handle_params(_, _, socket) do
    assigns = get_and_assign_page(socket.assigns.active_brand.id, nil)
    {:noreply, assign(socket, assigns)}
  end

  def get_and_assign_page(brand_id, page_number) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Media.paginate_media(brand_id, page: page_number)

    [
      medias: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end

  defp search_menu(assigns) do
    ~L"""
    <div class="pb-4 border-b border-gray-200 space-y-3 sm:flex sm:items-center sm:justify-between sm:space-x-4 sm:space-y-0">
      <div class="w-1/3">
        <form phx-submit="search">
          <label for="search_candidate" class="sr-only">Search</label>
          <div class="flex rounded-md shadow-sm">
            <div class="relative flex-grow focus-within:z-10">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <!-- Heroicon name: search -->
                <svg class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
                </svg>
              </div>
              <input id="search_candidate" name="search" value="<%= @search %>" class="hidden form-input w-full rounded-none rounded-l-md pl-10 transition ease-in-out duration-150 sm:block sm:text-sm sm:leading-5" placeholder="Search media" autocomplete="off">
            </div>
            <button type="submit" class="-ml-px relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm leading-5 font-medium rounded-r-md text-gray-700 bg-gray-50 hover:text-gray-500 hover:bg-white focus:outline-none focus:shadow-outline-blue focus:border-blue-300 active:bg-gray-100 active:text-gray-700 transition ease-in-out duration-150">
              <span class="ml-2">Search<span>
            </button>
          </div>
        </form>
      </div>
      <div class="col-span-1">
        <%= dropdown() %>
      </div>
    </div>
    """
  end

  defp media_card(media) do
    ~e"""
    <div class="cursor-pointer group" phx-click="open-slideover" phx-value-media_id="<%= media.id %>">
        <div class="bg-white shadow-sm rounded-sm overflow-hidden relative">
          <div class="absolute text-white p-2 z-10">
            <%= feather_icon("image", "w-6 h-6") %>
          </div>
          <div class="absolute text-white p-2 top-0 right-0 opacity-0 group-hover:opacity-100 z-10">
            <%= feather_icon("edit", "w-6 h-6") %>
          </div>
          <div class="md:flex-shrink-0 overflow-hidden">
            <img src="<%= media.thumbnail_url %>" class="w-full h-64 object-cover transform group-hover:scale-110 transition duration-150 ease-out">
          </div>
          <div class="px-4 py-2 mt-2">
            <span class="text-sm text-gray-400"><%= DateHelper.local_date(media.inserted_at) %></span>
            <h2 class="font-bold text-xl mb-2 text-gray-800 tracking-normal truncate"><%= media.title %></h2>
          </div>
        </div>
    </div>
    """
  end

  def slideover_body(assigns) do
    ~e"""
    <%= form_for @changeset, "#", [phx_submit: "save", phx_target: "#edit-media", class: "min-h-0 flex-1 flex flex-col"], fn f -> %>
      <div class="min-h-0 flex-1 flex flex-col space-y-6 overflow-y-scroll">
        <%= slideover_header(assigns) %>
        <div class="relative flex-1 px-4 sm:px-6">
          <%= slideover_content([f: f, media: @media]) %>
        </div>
      </div>
      <div class="flex-shrink-0 px-4 py-4 space-x-4 flex justify-end border-top">
        <%= slideover_footer(assigns) %>
      </div>
    <% end %>
    """
  end

  def slideover_header(assigns) do
    ~e"""
    <header class="relative h-96 bg-gray-700">
      <button type="button" phx-click="close-slideover"
      class="absolute top-5 right-8 text-gray-400 hover:text-gray-500 transition ease-in-out duration-100">
        <%= feather_icon("x", "h-6 w-6") %>
      </button>
      <img class="max-h-full max-w-full object-cover mx-auto" src="<%= @media.url %>" alt="">
    </header>
    """
  end

  def slideover_content(assigns) do
    ~e"""
    <div class="py-6 space-y-6 sm:py-0 sm:space-y-0 sm:divide-y sm:divide-gray-200">
      <!-- Project name -->
      <div class="space-y-1 px-4 sm:space-y-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 sm:py-5">
        <div>
          <%= label @f, :title, class: "block text-sm font-medium leading-5 text-gray-900 sm:mt-px sm:pt-2" %>
        </div>
        <div class="sm:col-span-2">
          <div class="rounded-md shadow-sm">
            <%= text_input @f, :title, class: "form-input block w-full sm:text-sm sm:leading-5" %>
          </div>
          <%= error_tag @f, :title %>
        </div>
      </div>

      <dl class="space-y-8 sm:space-y-0 divide-y divide-gray-200">
        <div class="sm:flex sm:space-x-6 sm:px-6 sm:py-5">
          <dt class="text-sm leading-5 font-medium text-gray-500 sm:w-40 sm:flex-shrink-0 lg:w-48">
            Uploaded on
          </dt>
          <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2">
            <p>
              <%= DateHelper.local_date(@media.inserted_at) %>
            </p>
          </dd>
        </div>

        <div class="sm:flex sm:space-x-6 sm:px-6 sm:py-5">
          <dt class="text-sm leading-5 font-medium text-gray-500 sm:w-40 sm:flex-shrink-0 lg:w-48">
            Dimensions
          </dt>
          <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2">
            <p>
              <%= @media.width %> x <%= @media.height %>
            </p>
          </dd>
        </div>

        <div class="sm:flex sm:space-x-6 sm:px-6 sm:py-5">
          <dt class="text-sm leading-5 font-medium text-gray-500 sm:w-40 sm:flex-shrink-0 lg:w-48">
            File Size
          </dt>
          <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2">
            <p>
              <%= Sizeable.filesize(@media.bytes) %>
            </p>
          </dd>
        </div>

        <div class="sm:flex sm:space-x-6 sm:px-6 sm:py-5 items-center">
          <dt class="text-sm leading-5 font-medium text-gray-500 sm:w-40 sm:flex-shrink-0 lg:w-48">
            File URL
          </dt>
          <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2 w-full">
            <div class="rounded-md shadow-sm">
              <input type="text" readonly class="form-input block w-full sm:text-sm sm:leading-5 bg-gray-100 cursor-not-allowed" value="<%= @media.url %>" />
            </div>
          </dd>
        </div>
      </dl>
    </div>
    """
  end

  def slideover_footer(_assigns) do
    ~e"""
    <div class="flex w-full justify-between">
      <div>
        <span class="inline-flex rounded-md shadow-sm">
          <button class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-red-600 hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red active:bg-red-700 transition duration-150 ease-in-out" phx-click="delete" data-confirm="Are you sure you want to delete this asset?">Delete</button>
        </span>
      </div>
      <div>
        <span class="inline-flex rounded-md shadow-sm">
          <button type="button" phx-click="close-slideover" class="py-2 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out">
            Cancel
          </button>
        </span>
        <span class="inline-flex rounded-md shadow-sm">
          <button type="submit" class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-blue-600 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out">
            Save
          </button>
        </span>
      </div>
    </div>
    """
  end

  def dropdown do
    ~e"""
    <div x-data="{ open: false }" @keydown.escape="open = false" @click.away="open = false" class="relative inline-block text-left">
    <div>
      <span class="rounded-md shadow-sm">
        <button @click="open = !open" type="button" class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition ease-in-out duration-150" id="options-menu" aria-haspopup="true" aria-expanded="true" x-bind:aria-expanded="open">
          Add Media
          <svg class="-mr-1 ml-2 h-5 w-5" x-description="Heroicon name: chevron-down" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"></path>
          </svg>
        </button>
      </span>
    </div>

    <div x-show="open" x-description="Dropdown panel, show/hide based on dropdown state." x-transition:enter="transition ease-out duration-100" x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100" x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100" x-transition:leave-end="transform opacity-0 scale-95" class="z-10 origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow">
      <div class="rounded-md bg-white shadow-xs" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
        <div class="py-1">
          <a href="#" @click="open = !open" id="upload_widget" phx-hook="UploadMedia" class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900" role="menuitem">
            <%= feather_icon("upload", "mr-3") %>
            Upload
          </a>
        </div>
        <div class="border-t border-gray-100"></div>
        <div class="py-1">
          <a href="#" @click="open = !open" phx-click="open-canva" class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900" role="menuitem">
            <i class="w-5 h-5 rounded-full flex items-center justify-center mr-3" style="background:#00c4cc;">
              <%= BordoWeb.Helpers.Svg.social_icon("canva_logo") %>
            </i>
            Canva
          </a>
          <a href="#" @click="open = !open" phx-click="open" phx-target="#unsplash-modal" class="group flex items-center px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-gray-100 hover:text-gray-900 focus:outline-none focus:bg-gray-100 focus:text-gray-900" role="menuitem">
            <i class="w-5 h-5 mr-3">
              <%= BordoWeb.Helpers.Svg.social_icon("unsplash_logo") %>
            </i>
            Unspash
          </a>
        </div>
      </div>
    </div>
    </div>
    """
  end
end
