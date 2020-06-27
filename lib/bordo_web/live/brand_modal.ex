defmodule BordoWeb.BrandModal do
  use BordoWeb, :live_component

  alias Bordo.Brands
  alias Bordo.Brands.Brand

  def mount(socket) do
    changeset = Brand.changeset(%Brand{}, %{})

    {:ok,
     assign(socket,
       state: "CLOSED",
       action: nil,
       changeset: changeset
     )}
  end

  def render(assigns) do
    ~L"""
    <div id="modal-parent">
      <div class="cursor-pointer">
        <div
          class="bg-blue-700 hover:bg-blue-600 transition duration-150 h-12 w-12 flex items-center justify-center text-blue-800 text-2xl font-semibold rounded-lg mb-1 overflow-hidden" phx-click="open-modal" phx-value-id="brand-modal">
          <%= feather_icon("plus", "w-56") %>
        </div>
      </div>
      <%= live_component @socket, BordoWeb.Components.Modal, id: @id do %>
        <%= f = form_for @changeset, "#", [phx_submit: :save, phx_target: "#modal-parent"] %>
          <div class="grid grid-cols-6 gap-6 mb-4">
            <div class="col-span-12">
              <%= text_input f, :name, class: "mt-1 form-input text-black block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autofocus: true, placeholder: "New Brand Name" %>
              <%= hidden_input f, :owner_id, value: @owner_id %>
              <%= hidden_input f, :team_id, value: @team_id %>
              <%= error_tag f, :name %>
            </div>
          </div>
          <div class="border-t border-gray-200 pt-2">
            <div class="flex justify-end">
              <span class="inline-flex rounded-md shadow-sm">
                <button type="button"
                  class="py-2 px-4 border border-gray-300 rounded-md text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition duration-150 ease-in-out"
                  @click="open = false">
                  Cancel
                </button>
              </span>
              <span class="ml-3 inline-flex rounded-md shadow-sm">
                <button type="submit"
                  class="inline-flex justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-red-500 hover:bg-red-400 focus:outline-none focus:border-red-600 focus:shadow-outline-red active:bg-red-600 transition duration-150 ease-in-out">
                  Add New Brand
                </button>
              </span>
            </div>
          </div>
        </form>
      <% end %>
    </div>
    """
  end

  def handle_event("save", %{"brand" => brand_params}, socket) do
    case Brands.create_brand(brand_params) do
      {:ok, brand} ->
        Brands.create_brand_team(%{team_id: brand_params["team_id"], brand_id: brand.id})

        {:noreply,
         socket
         |> redirect(to: Routes.live_path(socket, BordoWeb.LaunchpadLive, brand.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
