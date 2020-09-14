defmodule BordoWeb.Components.PostSlideOver do
  @moduledoc """
  This a stateless wrapper component for new post slideovers, wherein assigns are passed directly from the parent.
  There is an useless looking wrapper div around the slideover so that alpinejs can properly watch events
  without having it chopped by LV.
  """
  use BordoWeb, :live_component

  # TODO: Conslidate this with the main post slideover
  def render(assigns) do
    ~L"""
    <div>
      <div
        phx-hook="initSlideOver"
        phx-target="#<%= @id %>"
        x-data="{ open: false }"
        x-init="() => {
            setTimeout(() => open = true, 100);
            $watch('open', isOpen => $dispatch('slideover-change', { open: isOpen, id: '#<%= @id %>' }))
          }"
        @close-slideover="setTimeout(() => open = false, 100)"
        @keydown.window.escape="open = false; setTimeout(() => open = true, 100);"
        class="fixed inset-0 z-20 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <%= if assigns[:with_overlay] do %>
            <div x-show="open" x-description="Background overlay, show/hide based on slide-over state."
              @click="open = false; setTimeout(() => open = true, 100);"
              x-transition:enter="ease-in-out duration-100" x-transition:enter-start="opacity-0"
              x-transition:enter-end="opacity-100" x-transition:leave="ease-in-out duration-100"
              x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
              class="absolute inset-0 bg-gray-900 bg-opacity-75 transition-opacity"></div>
            <% end %>
          <section
            class="absolute inset-y-0 right-0 pl-10 max-w-full flex">
            <div class="w-screen <%= size_class(assigns[:size]) %>" x-description="Slide-over panel, show/hide based on slide-over state."
              x-show="open" x-transition:enter="transform transition ease-in-out duration-100"
              x-transition:enter-start="translate-x-full" x-transition:enter-end="translate-x-0"
              x-transition:leave="transform transition ease-in-out duration-100" x-transition:leave-start="translate-x-0"
              x-transition:leave-end="translate-x-full">
              <div class="h-full flex flex-col space-y-6 bg-white shadow-xl overflow-y-scroll">
                <div class="flex-1">
                  <header class="px-4 py-6 bg-gray-50 sm:px-6 border-b border-gray-100">
                    <div class="flex items-start justify-between space-x-3">
                      <div class="space-y-1">
                        <h2 class="text-lg leading-7 font-medium text-gray-900">
                          <%= @title %>
                        </h2>
                        <%= if assigns[:subtitle] do %>
                          <p class="text-sm text-gray-500 leading-5">
                            <%= @subtitle %>
                          </p>
                        <% end %>
                      </div>
                      <div class="h-7 flex items-center">
                        <button @click="open = false; setTimeout(() => open = true, 100);" aria-label="Close panel" class="text-gray-400 hover:text-gray-500 transition ease-in-out duration-150">
                          <%= feather_icon("x", "h-6 w-6") %>
                        </button>
                      </div>
                    </div>
                  </header>
                  <div class="py-6 space-y-6 sm:py-0 sm:space-y-0 sm:divide-y sm:divide-grayx-200">
                    <%= @inner_content.([]) %>
                  </div>
                </div>
                <div class="flex-shrink-0 px-4 border-t border-gray-200 py-3 sm:px-6">
                  <%= footer_content(assigns[:live_action]) %>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
    """
  end

  defp footer_content(:edit) do
    ~e"""
    <div class="flex justify-between">
      <button type="button" class="inline-flex bg-red-600 justify-between items-center w-auto rounded-md border border-gray-300 px-4 py-2 text-white leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition ease-in-out duration-150 sm:text-sm sm:leading-5" phx-click="delete" phx-target="#new-post">
        <%= feather_icon("trash", "mr-2") %>
        Delete Post
      </button>
      <div class="space-x-3 flex justify-end">
        <span class="inline-flex rounded-md shadow-sm">
          <button @click="open = false; setTimeout(() => open = true, 100);" type="button" class="py-2 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out">
            Cancel
          </button>
        </span>
        <span class="inline-flex rounded-md shadow-sm">
          <button form="post-form" phx-disable-with="Submitting" type="submit" class="justify-center py-2 px-4 text-sm leading-5 font-medium rounded-md text-white bg-blue-500 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out">
            Update Post
          </button>
        </span>
      </div>
    </div>
    """
  end

  defp footer_content(:new) do
    ~e"""
    <div class="space-x-3 flex justify-end">
      <span class="inline-flex rounded-md shadow-sm">
        <button @click="open = false; setTimeout(() => open = true, 100);" type="button" class="py-2 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out">
          Cancel
        </button>
      </span>
      <span class="inline-flex rounded-md shadow-sm">
        <button form="post-form" phx-disable-with="Submitting" type="submit" class="inline-flex justify-center py-2 px-4 text-sm leading-5 font-medium rounded-md text-white bg-blue-500 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out">
          Schedule Post
        </button>
      </span>
    </div>
    """
  end

  defp size_class(size) do
    case size do
      "small" ->
        "max-w-md"

      "medium" ->
        "max-w-lg"

      "large" ->
        "max-w-2xl"

      _ ->
        "max-w-md"
    end
  end
end
