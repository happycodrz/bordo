defmodule BordoWeb.Components.Pagination do
  use BordoWeb, :live_component

  def render(assigns) do
    ~L"""
    <nav class="border-t border-gray-200 px-4 flex items-center justify-between sm:px-0 pin-b">
      <div class="w-0 flex-1 flex">
        <a href="#" phx-click="nav" phx-target="<%= @target %>" phx-value-page="<%= @page_number - 1 %>" class="-mt-px border-t-2 border-transparent pt-4 pr-1 inline-flex items-center text-sm leading-5 font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-400 transition ease-in-out duration-150 <%= if @page_number <= 1, do: "pointer-events-none text-gray-600" %>">
          <!-- Heroicon name: arrow-narrow-left -->
          <svg class="mr-3 h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          Previous
        </a>
        </div>
        <div class="hidden md:flex">
        <%= for idx <-  Enum.to_list(1..@total_pages) do %>
          <a href="#" phx-click="nav" phx-target="<%= @target %>" phx-value-page="<%= idx %>" class="<%= pagination_link_css(@page_number, idx) %>">
            <%= idx %>
          </a>
        <% end %>
        </div>
        <div class="w-0 flex-1 flex justify-end">
        <a href="#" phx-click="nav" phx-target="<%= @target %>" phx-value-page="<%= @page_number + 1 %>" class="-mt-px border-t-2 border-transparent pt-4 pl-1 inline-flex items-center text-sm leading-5 font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-400 transition ease-in-out duration-150 <%= if @page_number >= @total_pages, do: "pointer-events-none text-gray-600" %>">
          Next
          <!-- Heroicon name: arrow-narrow-right -->
          <svg class="ml-3 h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </a>
      </div>
    </nav>
    """
  end

  defp pagination_link_css(page_number, idx) do
    if page_number == idx do
      "-mt-px border-t-2 border-indigo-500 pt-4 px-4 inline-flex items-center text-sm leading-5 font-medium text-indigo-600 focus:outline-none focus:text-indigo-800 focus:border-indigo-700 transition ease-in-out duration-150"
    else
      "-mt-px border-t-2 border-transparent pt-4 px-4 inline-flex items-center text-sm leading-5 font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-400 transition ease-in-out duration-150"
    end
  end
end
