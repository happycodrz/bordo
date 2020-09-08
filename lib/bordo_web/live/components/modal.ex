defmodule BordoWeb.Components.Modal do
  @moduledoc """
  This a stateful wrapper component for modals. There is an useless looking wrapper div around the modal
  so that alpinejs can properly watch events without having it chopped by LV.
  """
  use BordoWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, state: "CLOSED")}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("open", _, socket) do
    {:noreply, assign(socket, :state, "OPEN")}
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, assign(socket, :state, "CLOSED")}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <%= if @state == "OPEN" do %>
      <div
        phx-hook="InitModal"
        phx-target="#<%= @id %>"
        x-data="{ open: false }"
        x-init="() => {
          setTimeout(() => open = true, 100);
          $watch('open', isOpen => $dispatch('modal-change', { open: isOpen, id: '#<%= @id %>' }))
        }"
        x-show="open"
        @close-modal="setTimeout(() => open = false, 100)"
        class="z-50 fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0"
        >

        <!-- BACKDROP -->
        <div
          x-show="open"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0"
          x-transition:enter-end="opacity-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
          class="fixed inset-0 transition-opacity"
        >
          <div class="absolute inset-0 bg-gray-900 opacity-50"></div>
        </div>

        <!-- MODAL DIALOG -->
        <div
          x-show="open"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0 mb-2 sm:mb-8 sm:mt-2 sm:scale-95"
          x-transition:enter-end="opacity-100 mb-8 sm:mt-8 sm:scale-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100  mb-8 sm:mt-8  sm:scale-100"
          x-transition:leave-end="opacity-0  mb-2 sm:mb-8 sm:mt-2  sm:scale-95"
          class="relative <%= modal_size(assigns[:size]) %>">

          <div @click.away="open = false" class="relative flex flex-col bg-white border border-gray-200 rounded-lg">
            <!-- MODAL HEADER -->
            <div class="flex items-center justify-between p-4 border-b border-gray-200 rounded-t">
              <h5 class="mb-0 text-base font-semibold text-gray-500 uppercase"><%= assigns[:title] %></h5>
              <button type="button" @click="open = false" class="text-gray-400 hover:text-gray-500 focus:outline-none focus:text-gray-500 transition ease-in-out duration-150">
                &times;
              </button>
            </div>
            <!-- MODAL BODY -->
            <div class="relative flex-auto p-4 h-screen overflow-scroll">
              <%= @inner_content.([]) %>
            </div>
          </div>
        </div>
      </div>
      <% end %>
    </div>
    """
  end

  defp modal_size(size) do
    case size do
      "small" ->
        "w-full max-w-lg my-8 mx-auto sm:px-0 shadow-lg"

      "large" ->
        "w-full max-w-3xl my-8 mx-auto sm:px-0 shadow-lg"

      _ ->
        "w-full max-w-lg my-8 mx-auto sm:px-0 shadow-lg"
    end
  end
end
