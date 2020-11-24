defmodule BordoWeb.Composer do
  use BordoWeb, :live_component

  alias Bordo.{
    Channels,
    Media,
    Posts,
    Posts.Post,
    PostVariants.PostVariant,
    PostVariants.PostVariantMedia
  }

  alias Ecto.Changeset
  alias Timex.Timezone

  def preload([assigns]) do
    live_action =
      if is_nil(assigns[:post_id]) do
        :new
      else
        :edit
      end

    post = get_post(assigns[:post_id], assigns[:team].timezone)
    changeset = Posts.change_post(post)
    existing_variants = existing_variants(%{changeset: changeset, post: post})

    # reject existing channels in the post-variant changeset
    channels = fetch_available_channels(assigns[:active_brand].id)

    picked_channels = existing_variants |> Enum.map(& &1.channel_id)
    IO.inspect(picked_channels)

    [
      Map.merge(assigns, %{
        channels: channels,
        picked_channels: picked_channels,
        changeset: changeset,
        live_action: live_action,
        post: post
      })
    ]
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    params = post_params |> prepare_data(socket.assigns.team.timezone)

    updated_changeset =
      Posts.change_post(socket.assigns.post, params)
      |> prepare_error_changeset(socket.assigns.team.timezone)

    {:noreply, assign(socket, changeset: updated_changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    params = post_params |> prepare_data(socket.assigns.team.timezone)

    if socket.assigns.live_action == :edit do
      case Posts.update_and_schedule_post(socket.assigns.post, params) do
        {:ok, _post} ->
          {:noreply,
           socket
           |> put_flash(:success, "Your post was updated")
           |> redirect(to: Routes.bordo_path(socket, :schedule, socket.assigns.active_brand.slug))}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           assign(socket,
             changeset: prepare_error_changeset(changeset, socket.assigns.team.timezone)
           )}
      end
    else
      case Posts.create_and_schedule_post(params) do
        {:ok, _post} ->
          {:noreply,
           socket
           |> put_flash(:success, "Your post is scheduled")
           |> redirect(to: Routes.bordo_path(socket, :schedule, socket.assigns.active_brand.slug))}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply,
           assign(socket,
             changeset: prepare_error_changeset(changeset, socket.assigns.team.timezone)
           )}
      end
    end
  end

  def handle_event("delete", _params, socket) do
    Posts.delete_post(socket.assigns.post)

    {:noreply,
     socket
     |> put_flash(:success, "Your post was removed")
     |> redirect(to: Routes.bordo_path(socket, :schedule, socket.assigns.active_brand.slug))}
  end

  def handle_event("add-variant", %{"channel_id" => channel_id}, socket) do
    variants =
      existing_variants(socket.assigns)
      |> add_variant(channel_id)

    changeset =
      socket.assigns.changeset
      |> Changeset.put_assoc(:post_variants, variants)

    picked_channels = Enum.concat(socket.assigns.picked_channels, [channel_id])

    {:noreply, assign(socket, changeset: changeset, picked_channels: picked_channels)}
  end

  def handle_event("remove-variant", %{"channel_id" => channel_id}, socket) do
    variants =
      existing_variants(socket.assigns)
      |> remove_variant(channel_id)

    changeset =
      socket.assigns.changeset
      |> Changeset.put_assoc(:post_variants, variants)

    picked_channels = List.delete(socket.assigns.picked_channels, channel_id)

    {:noreply, assign(socket, changeset: changeset, picked_channels: picked_channels)}
  end

  def handle_event(
        "media-removed",
        %{"post_variant_media_id" => post_variant_media_id, "post_variant_id" => post_variant_id},
        socket
      ) do
    variants =
      existing_variants(socket.assigns)
      |> remove_media(post_variant_media_id, post_variant_id)

    changeset =
      socket.assigns.changeset
      |> Changeset.put_assoc(:post_variants, variants)

    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("close-slideover", _data, socket) do
    {:noreply, socket |> assign(show_slideover: false, changeset: nil)}
  end

  def handle_event("open-slideover", %{"post_id" => post_id}, socket) do
    {:noreply, build_slideover_assigns(socket, post_id)}
  end

  def handle_event("open-slideover", _data, socket) do
    {:noreply, build_slideover_assigns(socket, nil)}
  end

  def handle_event("selecting-media", %{"post_variant_id" => post_variant_id}, socket) do
    send_update(BordoWeb.Components.Modal, id: "choose-media", state: "OPEN")

    {:noreply,
     socket
     |> assign(
       selected_post_variant_id: post_variant_id,
       media: Media.list_media_for_brand(socket.assigns.active_brand.id)
     )}
  end

  def handle_event("media-selected", %{"media_id" => media_id}, socket) do
    variants =
      existing_variants(socket.assigns)
      |> add_media(media_id, socket)

    changeset =
      socket.assigns.changeset
      |> Changeset.put_assoc(:post_variants, variants)

    send_update(BordoWeb.Components.Modal, id: "choose-media", state: "CLOSED")
    {:noreply, assign(socket, changeset: changeset)}
  end

  def build_slideover_assigns(socket, post_id) do
    live_action =
      if is_nil(post_id) do
        :new
      else
        :edit
      end

    post = get_post(post_id, socket.assigns.team.timezone)
    changeset = Posts.change_post(post)
    existing_variants = existing_variants(%{changeset: changeset, post: post})

    # reject existing channels in the post-variant changeset
    channels = fetch_available_channels(socket.assigns.active_brand.id)

    picked_channels = existing_variants |> Enum.map(& &1.channel_id)

    socket
    |> assign(
      show_slideover: true,
      channels: channels,
      picked_channels: picked_channels,
      changeset: changeset,
      live_action: live_action,
      post: post
    )
  end

  def prepare_error_changeset(changeset, timezone) do
    changeset
    |> Changeset.put_change(
      :scheduled_for,
      Changeset.get_field(changeset, :scheduled_for) |> format_for_input(timezone)
    )
    |> Changeset.update_change(:post_variants, &inject_media_when_empty(&1))
  end

  def inject_media_when_empty(pv_changeset) do
    pv_changeset
    |> Enum.map(fn pv ->
      if Enum.empty?(Changeset.get_field(pv, :post_variant_media)) do
        Changeset.put_change(pv, :post_variant_media, [%PostVariantMedia{}])
      else
        pv
      end
    end)
  end

  def handle_pv_changeset(kvpair) do
    kvpair
  end

  def add_media(existing_variants, media_id, socket) do
    existing_variants
    |> Enum.map(fn pv ->
      if pv.id == socket.assigns.selected_post_variant_id ||
           pv.temp_id == socket.assigns.selected_post_variant_id do
        Posts.change_post_variant(
          pv,
          %{
            post_variant_media: [
              %{
                id: generate_temp_id(),
                media_id: media_id
              }
            ]
          }
        )
      else
        pv
      end
    end)
  end

  def remove_media(existing_variants, post_variant_media_id, post_variant_id) do
    existing_variants
    |> Enum.map(fn pv ->
      if (pv.id == post_variant_id || pv.temp_id == post_variant_id) &&
           pv.post_variant_media
           |> Enum.map(& &1.media_id)
           |> Enum.any?(&(&1 == post_variant_media_id)) do
        Posts.change_post_variant(
          pv,
          %{
            channel_id: pv.channel_id,
            post_variant_media: [%{id: generate_temp_id()}]
          }
        )
      else
        pv
      end
    end)
  end

  def prepare_data(params, timezone) do
    params
    |> convert_scheduled_for_to_utc(timezone)
    |> drop_empty_media()
  end

  defp drop_empty_media(params) do
    if is_nil(Map.get(params, "post_variants")) do
      params
    else
      Map.put(
        params,
        "post_variants",
        Map.new(params["post_variants"], fn {k, v} ->
          {k, Map.new(v, &handle_post_variant_pair/1)}
        end)
      )
    end
  end

  defp handle_post_variant_pair({"post_variant_media", pvm}) do
    {"post_variant_media", reject_empty_media(pvm)}
  end

  defp handle_post_variant_pair(kvpair), do: kvpair

  defp reject_empty_media(mmap) do
    mmap
    |> Enum.reject(&match?({_, %{"media_id" => ""}}, &1))
    |> Map.new()
  end

  def fetch_available_channels(brand_id) do
    Channels.list_channels(brand_id: brand_id)
  end

  def get_post(nil, timezone),
    do: %Post{scheduled_for: Timex.now() |> format_for_input(timezone), post_variants: []}

  def get_post(id, timezone) do
    post = Posts.get_post!(id)
    scheduled_for = Map.get(post, :scheduled_for)
    Map.replace!(post, :scheduled_for, format_for_input(scheduled_for, timezone))
  end

  defp format_for_input(time, timezone) do
    time
    |> Timezone.convert(timezone)
    |> Timex.format!("%Y-%m-%d %H:%M", :strftime)
  end

  defp convert_scheduled_for_to_utc(post_params, timezone) do
    post_params
    |> Map.replace!(
      "scheduled_for",
      post_params
      |> Map.get("scheduled_for")
      |> Timex.parse!("%Y-%m-%d %H:%M", :strftime)
      |> Timex.to_datetime(timezone)
      |> Timezone.convert("UTC")
    )
  end

  defp media_selector(pv_media, post_variant_id) do
    # TODO: Fix this n+1
    media_id = Changeset.get_field(pv_media.source, :media_id)

    media =
      if is_nil(media_id) do
        nil
      else
        Media.get_media!(media_id)
      end

    assigns = %{}

    ~L"""
    <%= if !is_nil(media) do %>
      <span class="inline-block relative">
        <img class="h-32 w-full object-cover rounded-md" src="<%= media.thumbnail_url %>" alt="">
        <span phx-click="media-removed" phx-target="#new-post" phx-value-post_variant_id="<%= post_variant_id %>" phx-value-post_variant_media_id="<%= media_id %>" class="cursor-pointer absolute flex items-center justify-content-center top-0 right-0 block h-5 w-5 transform -translate-y-1/2 translate-x-1/2 rounded-full text-white shadow-solid bg-gray-300">
          <%= feather_icon("x", "w-2.5 h-2.5") %>
        </span>
      </span>
    <% else %>
      <div class="bg-gray-50 border border-gray-100 cursor-pointer flex flex-col group hover:bg-blue-100 hover:border-blue-300 items-center justify-center p-4 rounded" phx-click="selecting-media" phx-target="#new-post" phx-value-post_variant_id="<%= post_variant_id %>">
        <span class="group-hover:text-blue-600 mb-2 text-center">Add Media</span>
        <button type="button" class="border-2 border-dashed border-gray-200 group-hover:border-blue-400 group-hover:text-blue-600 h-8 hover:text-gray-500 inline-flex items-center justify-center rounded-full text-gray-400 w-8">
          <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
          </svg>
        </button>
      </div>
    <% end %>
    """
  end

  defp channel_selector(channels, picked_channels) do
    ~e"""
    <div>
      <%= for channel <- channels do %>
        <div class="flex items-center mb-2">
          <button type="button" @click="on = !on" phx-click="<%= channel_selector_click(channel, picked_channels) %>" phx-target="#new-post" phx-value-channel_id="<%= channel.id %>" :aria-pressed="on.toString()" aria-pressed="false" aria-labelledby="toggleLabel" x-data="{ on: <%= channel_added?(channel.id, picked_channels) %> }" :class="{ 'bg-gray-200': !on, 'bg-indigo-600': on }" class="bg-gray-200 relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            <span class="sr-only">Use setting</span>
            <span aria-hidden="true" :class="{ 'translate-x-5': on, 'translate-x-0': !on }" class="translate-x-0 inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200"></span>
          </button>
          <span class="ml-3" id="toggleLabel">
            <span class="text-sm font-medium text-gray-900"><%= channel_name(channel) %></span>
          </span>
        </div>
      <% end %>
    </div>
    """
  end

  defp channel_selector_click(channel, picked_channels) do
    if channel_added?(channel.id, picked_channels) do
      "remove-variant"
    else
      "add-variant"
    end
  end

  defp channel_selector_old(channels, picked_channels) do
    ~e"""
    <div class="space-y-1 px-4 sm:space-y-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 sm:py-5">
      <div class="sm:col-span-2">
        <span class="block text-sm font-medium leading-5 text-gray-900 sm:mt-px sm:pt-2">
          <%= for channel <- channels do %>
            <span class="inline-flex rounded-md shadow">
              <%= if channel_added?(channel.id, picked_channels) do %>
                <button type="button" phx-click="remove-variant" phx-target="#new-post" phx-value-channel_id="<%= channel.id %>" class="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150">
                  Remove <%= channel_name(channel) %>
                </button>
              <% else %>
                <button type="button" phx-click="add-variant" phx-target="#new-post" phx-value-channel_id="<%= channel.id %>" class="inline-flex items-center px-3 py-2 border border-gray-300 text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150">
                  Add <%= channel_name(channel) %>
                </button>
              <% end %>
            </span>
          <% end %>
        </span>
      </div>
    </div>
    """
  end

  defp footer_content(nil), do: footer_content(:new)

  defp footer_content(:edit) do
    ~e"""
    <div class="flex justify-between">
      <button type="button" class="inline-flex items-center justify-center py-2 px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-red-500 hover:bg-red-400 focus:outline-none focus:border-red-700 focus:shadow-outline-red active:bg-red-700 transition duration-150 ease-in-out" phx-click="delete" phx-target="#new-post">
        <%= feather_icon("trash", "mr-2 w-4 h-4") %>
        Delete Post
      </button>
      <div class="space-x-3 flex justify-end">
        <span class="inline-flex rounded-md shadow">
          <button form="post-form" phx-disable-with="Submitting" type="submit" class="justify-center py-2 px-4 text-sm leading-5 font-medium rounded-md text-white bg-blue-500 hover:bg-blue-400 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-400 transition duration-150 ease-in-out">
            Update Post
          </button>
        </span>
      </div>
    </div>
    """
  end

  defp footer_content(:new) do
    ~e"""
    <div class="space-x-3 flex justify-end">
      <span class="inline-flex rounded-md shadow">
        <button form="post-form" phx-disable-with="Submitting" type="submit" class="justify-center py-2 px-4 text-sm leading-5 font-medium rounded-md text-white bg-blue-500 hover:bg-blue-400 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-400 transition duration-150 ease-in-out">
          Schedule Post
        </button>
      </span>
    </div>
    """
  end

  defp channel_added?(channel_id, picked_channels) do
    Enum.member?(picked_channels, channel_id)
  end

  defp existing_variants(assigns) do
    Changeset.get_field(assigns.changeset, :post_variants)
  end

  defp add_variant(existing_variants, channel_id) do
    existing_variants
    |> Enum.concat([
      Posts.change_post_variant(%PostVariant{
        temp_id: generate_temp_id(),
        channel_id: channel_id,
        post_variant_media: []
      })
    ])
  end

  defp remove_variant(existing_variants, remove_id) do
    existing_variants
    |> Enum.reject(fn variant ->
      variant.channel_id == remove_id
    end)
  end

  def channel_name(channel) do
    if is_nil(channel.label) do
      String.capitalize(channel.network)
    else
      String.capitalize(channel.network) <> ": " <> channel.label
    end
  end

  defp generate_temp_id,
    do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
end
