defmodule BordoWeb.Components.ModalLive do
  use BordoWeb, :live_component

  @defaults %{
    left_button: "Cancel",
    left_button_action: nil,
    left_button_param: nil,
    right_button: "OK",
    right_button_action: nil,
    right_button_param: nil
  }

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{id: _id} = assigns, socket) do
    {:ok, assign(socket, Map.merge(@defaults, assigns))}
  end

  def render(assigns) do
    ~L"""
    <div class="fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center" phx-click="modal-close">
    <!--
    Background overlay, show/hide based on modal state.

    Entering: "ease-out duration-300"
      From: "opacity-0"
      To: "opacity-100"
    Leaving: "ease-in duration-200"
      From: "opacity-100"
      To: "opacity-0"
    -->
    <div class="fixed inset-0 transition-opacity">
    <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
    </div>

    <!--
    Modal panel, show/hide based on modal state.

    Entering: "ease-out duration-300"
      From: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
      To: "opacity-100 translate-y-0 sm:scale-100"
    Leaving: "ease-in duration-200"
      From: "opacity-100 translate-y-0 sm:scale-100"
      To: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
    -->
    <div class="bg-white rounded-lg px-4 pt-5 pb-4 overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full sm:p-6" role="dialog" aria-modal="true" aria-labelledby="modal-headline">
    <div class="sm:flex sm:items-start">
      <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
        <svg class="h-6 w-6 text-red-600" stroke="currentColor" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
        </svg>
      </div>
      <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
        <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-headline">
          Deactivate account
        </h3>
        <div class="mt-2">
          <p class="text-sm leading-5 text-gray-500">
            Are you sure you want to deactivate your account? All of your data will be permanently removed from our servers forever. This action cannot be undone.
          </p>
        </div>
      </div>
    </div>
    <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
      <span class="flex w-full rounded-md shadow-sm sm:ml-3 sm:w-auto">
        <button type="button" class="inline-flex justify-center w-full rounded-md border border-transparent px-4 py-2 bg-red-600 text-base leading-6 font-medium text-white shadow-sm hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red transition ease-in-out duration-150 sm:text-sm sm:leading-5">
          Deactivate
        </button>
      </span>
      <span class="mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto">
        <button type="button" class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition ease-in-out duration-150 sm:text-sm sm:leading-5">
          Cancel
        </button>
      </span>
    </div>
    </div>
    </div>
    """

    # ~L"""
    # <div id="modal-<%= @id %>">
    #   <!-- Modal Background -->
    #   <div class="modal-container"
    #       phx-hook="ScrollLock">
    #     <div class="modal-inner-container">
    #       <div class="modal-card">
    #         <div class="modal-inner-card">
    #           <!-- Title -->
    #           <%= if @title != nil do %>
    #           <div class="modal-title">
    #             <%= @title %>
    #           </div>
    #           <% end %>

    #           <!-- Body -->
    #           <%= if @body != nil do %>
    #           <div class="modal-body">
    #             <%= @body %>
    #           </div>
    #           <% end %>

    #           <!-- Buttons -->
    #           <div class="modal-buttons">
    #               <!-- Left Button -->
    #               <button class="left-button"
    #                       type="button"
    #                       phx-click="left-button-click"
    #                       phx-target="#modal-<%= @id %>">
    #                 <div>
    #                   <%= @left_button %>
    #                 </div>
    #               </button>
    #               <!-- Right Button -->
    #               <button class="right-button"
    #                       type="button"
    #                       phx-click="right-button-click"
    #                       phx-target="#modal-<%= @id %>">
    #                 <div>
    #                   <%= @right_button %>
    #                 </div>
    #               </button>
    #           </div>
    #         </div>
    #       </div>
    #     </div>
    #   </div>
    # </div>
    # """
  end
end
