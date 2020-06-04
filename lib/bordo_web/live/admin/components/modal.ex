defmodule BordoWeb.Components.ModalLive do
  use BordoWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  # def update(%{id: _id} = assigns, socket) do
  #   {:ok, assign(socket, assigns)}
  # end

  def render(assigns) do
    modal_id = assigns.id

    ~L"""
    <div>
      <%= if @show_modal do %>
        <div class="fixed bottom-0 inset-x-0 z-10 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center" >
        <!--
        Background overlay, show/hide based on modal state.

        Entering: "ease-out duration-300"
          From: "opacity-0"
          To: "opacity-100"
        Leaving: "ease-in duration-200"
          From: "opacity-100"
          To: "opacity-0"
        -->
        <div class="fixed inset-0 transition-opacity" phx-hook="ScrollLock" phx-click="modal-close" id="modal-<%= modal_id %>" phx-target="#modal-<%= modal_id %>">
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
            <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
              <%= @inner_content.([]) %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("modal-close", %{}, socket) do
    # send(
    #   self(),
    #   {:button_clicked}
    # )

    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_info({:button_clicked}, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end
end
