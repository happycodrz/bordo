defmodule BordoWeb.EditPost do
  use BordoWeb, :live_component

  alias Bordo.Media
  alias Bordo.Posts
  alias Bordo.PostVariants
  alias Ecto.Changeset

  def handle_event("save", %{"post" => post_params}, socket) do
    case Posts.update_and_schedule_post(socket.assigns.post, post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> redirect(
           to: Routes.live_path(socket, BordoWeb.CalendarLive, socket.assigns.active_brand.slug)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event(
        "media-removed",
        %{"post_variant_media_id" => post_variant_media_id},
        socket
      ) do
    pv_media = PostVariants.get_post_variant_media!(post_variant_media_id)
    PostVariants.delete_post_variant_media(pv_media)
    post = socket.assigns.post

    updated_post = Posts.get_post!(post.id)
    updated_changeset = Posts.change_post(updated_post)
    {:noreply, socket |> assign(post: updated_post, changeset: updated_changeset)}
  end

  def handle_event("selecting-media", %{"post_variant_id" => post_variant_id}, socket) do
    send_update(BordoWeb.Components.Modal, id: "choose-media", state: "OPEN")
    {:noreply, socket |> assign(:selected_post_variant_id, post_variant_id)}
  end

  def handle_event("media-selected", %{"media_id" => media_id}, socket) do
    post = socket.assigns.post
    picked_media = Media.get_media!(media_id)
    post_variant_id = socket.assigns.selected_post_variant_id

    send_update(BordoWeb.Components.Modal, id: "choose-media", state: "CLOSED")

    updated_changeset =
      socket.assigns.changeset
      |> Changeset.put_assoc(
        :post_variants,
        post.post_variants
        |> Enum.map(fn pv ->
          if pv.id == post_variant_id do
            pv
            |> Changeset.change(post_variant_media: [%{media_id: picked_media.id}])
          else
            pv
          end
        end)
      )

    # TODO: Use changesets to track
    # updated_changeset =
    #   Changeset.update_change(socket.assigns.changeset, :post_variants, fn pvs ->
    #     Enum.map(pvs, fn pv ->
    #       if Changeset.get_field(pv, :id) == post_variant_id do
    #         IO.inspect("A MATCH")
    #         pv |> Changeset.change(post_variant_media: %{media_id: picked_media.id})
    #       else
    #         IO.inspect("NO MATCH")
    #         pv
    #       end
    #     end)
    #   end)

    {:noreply, socket |> assign(changeset: updated_changeset)}
  end

  def handle_event("delete", _params, socket) do
    Posts.delete_post(socket.assigns.post)

    {:noreply,
     redirect(socket,
       to: Routes.live_path(socket, BordoWeb.CalendarLive, socket.assigns.active_brand.slug)
     )}
  end

  defp variant_status_badge(pv) do
    class =
      case pv.status do
        "success" -> "success"
        "failed" -> "danger"
        _ -> "light"
      end

    ~e"""
    <span class="badge badge-pill badge-<%= class %>"><%= pv.status %></span>
    """
  end

  defp media_selector(pv_media, post_variant_id) do
    # TODO: Fix this n+1
    media_id = pv_media.source |> Changeset.get_field(:media_id)

    media =
      if is_nil(media_id) do
        nil
      else
        Bordo.Media.get_media!(media_id)
      end

    assigns = %{}

    ~L"""
    <%= if !is_nil(media) do %>
      <div class="overflow-hidden relative rounded overflow-xhidden h-100 flex flex-column justify-content-center">
        <div class="absolute top-4 right-4 bg-gray-100 bg-opacity-50 text-gray-700 p-2 rounded-full cursor-pointer" data-confirm="This image will be immediately removed, are you sure?" phx-click="media-removed" phx-target="#edit-post-inner" phx-value-post_variant_media_id="<%= pv_media.data.id %>">
          <%= feather_icon("trash", "w-6 h-6") %>
        </div>
        <img src="<%= media.thumbnail_url %>" />
      </div>
    <% else %>
      <div class="p-3 bg-light border rounded h-100 flex flex-column justify-content-center cursor-pointer" phx-click="selecting-media" phx-target="#edit-post-inner" phx-value-post_variant_id="<%= post_variant_id %>">
        <span class="text-center mb-2">Add Media</span>
        <span class="text-center">
          <button type="button" class="inline-flex h-8 w-8 items-center justify-center rounded-full border-2 border-dashed border-gray-200 text-gray-400 hover:text-gray-500 transition ease-in-out duration-150" aria-label="Add team member">
            <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </span>
      </div>
    <% end %>
    """
  end
end
