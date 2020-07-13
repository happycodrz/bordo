defmodule BordoWeb.Components.SlideOver do
  @moduledoc """
  This a stateless wrapper component for slideovers, wherein assigns are passed directly from the parent.
  There is an useless looking wrapper div around the slideover so that alpinejs can properly watch events
  without having it chopped by LV.
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
          $watch('open', isOpen => $dispatch('slideover-change', { open: isOpen }))
        }"
        x-show="open"
        close-slideover="setTimeout(() => open = false, 100)"
        class="fixed inset-0 overflow-hidden z-20">
        <div class="absolute inset-0 overflow-hidden">
          <section @click.away="open = false; setTimeout(() =>open = true, 1000);" class="absolute inset-y-0 right-0 pl-10 max-w-full flex">
            <div class="w-screen max-w-md" x-description="Slide-over panel, show/hide based on slide-over state." x-show="open" x-transition:enter="transform transition ease-in-out duration-500 sm:duration-300" x-transition:enter-start="translate-x-full" x-transition:enter-end="translate-x-0" x-transition:leave="transform transition ease-in-out duration-500 sm:duration-300" x-transition:leave-start="translate-x-0" x-transition:leave-end="translate-x-full">
              <div class="h-full flex flex-col space-y-6 py-6 bg-white shadow-xl overflow-y-scroll">
                <header class="px-4 sm:px-6">
                  <div class="flex items-start justify-between space-x-3">
                    <h2 class="text-lg leading-7 font-medium text-gray-900">
                      <%= @title %>
                    </h2>
                    <div class="h-7 flex items-center">
                      <button @click="open = false; setTimeout(() =>open = true, 1000);" aria-label="Close panel" class="text-gray-400 hover:text-gray-500 transition ease-in-out duration-150">
                        <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                      </button>
                    </div>
                  </div>
                </header>
                <%= @inner_content.([]) %>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
    """
  end
end
