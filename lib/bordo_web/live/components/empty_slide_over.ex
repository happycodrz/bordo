defmodule BordoWeb.Components.EmptySlideOver do
  @moduledoc """
  A slideover component that has a completely empty body to allow more source styling
  """
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div>
      <div
        phx-hook="initSlideOver"
        x-data="{ open: false }"
        x-init="() => {
            setTimeout(() => open = true, 100);
            $watch('open', isOpen => $dispatch('slideover-change', { open: isOpen, id: '#<%= @id %>' }))
          }"
        @close-slideover="setTimeout(() => open = false, 100)"
        @keydown.window.escape="open = false; setTimeout(() => open = true, 100);"
        class="fixed inset-0 z-20 overflow-hidden"
        id="empty-slideover">
        <div class="absolute inset-0 overflow-hidden">
          <%= if assigns[:with_overlay] do %>
            <div x-show="open" x-description="Background overlay, show/hide based on slide-over state."
              x-transition:enter="ease-in-out duration-100" x-transition:enter-start="opacity-0"
              x-transition:enter-end="opacity-100" x-transition:leave="ease-in-out duration-100"
              x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
              class="absolute inset-0 bg-gray-900 bg-opacity-75 transition-opacity"></div>
            <% end %>
          <section @click.away="open = false; setTimeout(() => open = true, 100);"
            class="absolute inset-y-0 right-0 pl-10 max-w-full flex">
            <div class="w-screen <%= size_class(assigns[:size]) %>" x-description="Slide-over panel, show/hide based on slide-over state."
              x-show="open" x-transition:enter="transform transition ease-in-out duration-100"
              x-transition:enter-start="translate-x-full" x-transition:enter-end="translate-x-0"
              x-transition:leave="transform transition ease-in-out duration-100" x-transition:leave-start="translate-x-0"
              x-transition:leave-end="translate-x-full">
              <div class="h-full flex flex-col space-y-6 bg-white shadow-xl overflow-y-scroll">
                <%= @inner_content.([]) %>
              </div>
            </div>
          </section>
        </div>
      </div>
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
