defmodule BordoWeb.BrandModal do
  use BordoWeb, :live_component

  alias Bordo.Brands
  alias Bordo.Brands.Brand

  # import Phoenix.HTML.Form

  def render(assigns) do
    changeset = Brand.changeset(%Brand{}, %{})

    ~L"""
    <div>
      <div class="cursor-pointer">
        <div
          class="bg-white opacity-25 h-12 w-12 flex items-center justify-center text-black text-2xl font-semibold rounded-lg mb-1 overflow-hidden" phx-click="modal-open" phx-target="<%= @myself %>">
          <svg class="fill-current h-10 w-10 block" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
            <path
              d="M16 10c0 .553-.048 1-.601 1H11v4.399c0 .552-.447.601-1 .601-.553 0-1-.049-1-.601V11H4.601C4.049 11 4 10.553 4 10c0-.553.049-1 .601-1H9V4.601C9 4.048 9.447 4 10 4c.553 0 1 .048 1 .601V9h4.399c.553 0 .601.447.601 1z" />
          </svg>
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
    owner_id = socket.assigns.current_identity.user_id

    case Brands.create_brand(brand_params |> Enum.into(%{"owner_id" => owner_id})) do
      {:ok, brand} ->
        team_id = socket.assigns.current_identity.team_id
        Brands.create_brand_team(%{team_id: team_id, brand_id: brand.id})

        {:noreply,
         socket
         |> redirect(to: Routes.live_path(socket, BordoWeb.ReactLive, brand.slug))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
