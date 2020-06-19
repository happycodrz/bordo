defmodule BordoWeb.BrandModal do
  use BordoWeb, :live_component

  alias Bordo.Brands
  alias Bordo.Brands.Brand

  def render(assigns) do
    changeset = Brand.changeset(%Brand{}, %{})

    ~L"""
    <div>
      <div class="cursor-pointer">
        <div
          class="bg-blue-700 hover:bg-blue-600 transition duration-150 h-12 w-12 flex items-center justify-center text-blue-800 text-2xl font-semibold rounded-lg mb-1 overflow-hidden" phx-click="modal-open" phx-target="<%= @myself %>">
          <%= feather_icon("plus", "w-56") %>
        </div>
      </div>
      <%= if @show_modal do %>
        <%= BordoWeb.SharedView.render("new_brand_modal.html", changeset: changeset, myself: @myself) %>
      <% end %>
    </div>
    """
  end

  def handle_event("modal-open", _unsigned_params, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("modal-close", _unsigned_params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("save", %{"brand" => brand_params}, socket) do
    owner_id = socket.assigns.user_id

    case Brands.create_brand(brand_params |> Enum.into(%{"owner_id" => owner_id})) do
      {:ok, brand} ->
        team_id = socket.assigns.team_id
        Brands.create_brand_team(%{team_id: team_id, brand_id: brand.id})

        {:noreply,
         socket
         |> redirect(to: Routes.live_path(socket, BordoWeb.LaunchpadLive, brand.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
