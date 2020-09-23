defmodule BordoWeb.Media.UnsplashSearch do
  use BordoWeb, :live_component

  @client_id "oEPr7PwuQW8HmQB7q6JPdzC5y2pxQtnErE5zuZO1lTY"

  def render(assigns) do
    ~L"""
      <div id="unsplash-search">
        <%= if @loading do %>
          <div class="bg-gray-50 overflow-hidden rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <span class="spinner"></span><span class="ml-3">Uploading...<span>
            </div>
          </div>
        <% else %>
          <form phx-submit="unsplash-search" phx-target="#unsplash-search" class="mb-4">
            <input name="search" value="<%= @unsplash_search %>" class="bg-white focus:outline-none focus:shadow-outline border border-gray-300 rounded-lg py-2 px-4 block w-full appearance-none leading-normal" autocomplete="off" autofocus placeholder="Search Unsplash" %>
            <p class="mt-2 text-xs text-gray-500" id="email-description">Press Enter to search.</p>
          </form>
          <%= if Enum.any?(@unsplash_results) do %>
            <div class="card-columns mb-4">
              <%= for result <- @unsplash_results do %>
                <%= image_card(result) %>
              <% end %>
            </div>
            <div class="grid grid-cols-2">
              <div class="cursor-pointer" phx-click="nav" phx-value-page="<%= Enum.max([1, (@page - 1)]) %>" phx-target="#unsplash-search">&larr; Previous Page</div>
              <div class="text-right cursor-pointer" phx-click="nav" phx-value-page="<%= @page + 1 %>" phx-target="#unsplash-search">Next Page &rarr;</div>
            </div>
          <% else %>
            <div class="bg-gray-50 overflow-hidden rounded-lg">
              <div class="px-4 py-5 sm:p-6">
                No results, try a different search
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    """
  end

  def handle_event("unsplash-search", %{"search" => search}, socket) do
    {:noreply,
     socket
     |> assign(:unsplash_results, fetch_results(search, socket.assigns.page))
     |> assign(:unsplash_search, search)}
  end

  def handle_event("image-selected", %{"url" => url}, socket) do
    send(self(), {:upload, url})
    {:noreply, socket |> assign(:loading, true)}
  end

  def handle_event("nav", %{"page" => page}, socket) do
    {:noreply,
     socket
     |> assign(
       :unsplash_results,
       fetch_results(socket.assigns.unsplash_search, page)
     )
     |> assign(:page, String.to_integer(page))}
  end

  def image_card(image_data) do
    ~e"""
      <div class="inline-block rounded-sm relative cursor-pointer overflow-hidden" phx-click="image-selected" phx-value-url="<%= image_data["urls"]["full"] %>" phx-target="#unsplash-search">
        <img src="<%= image_data["urls"]["small"] %>">
        <div class="flex items-end absolute top-0 left-0 right-0 bottom-0 p-3" style="background: linear-gradient(10deg, rgba(0, 0, 0, 0.4), transparent);">
          <div class="text-gray-50 items-center flex">
            <img src="<%= image_data["user"]["profile_image"]["small"] %>" alt="<%= image_data["user"]["name"] %>" class="rounded-circle mr-3" />
            <div class="flex-1"><%= image_data["user"]["name"] %></div>
          </div>
        </div>
      </div>
    """
  end

  def fetch_results(search, page) do
    HTTPoison.get!(
      "https://api.unsplash.com/search/photos?page=#{page}&query=#{URI.encode(search)}&client_id=#{
        @client_id
      }"
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("results")
  end
end
