defmodule BordoWeb.BordoLive do
  use BordoWeb, :client_live_view
  use Timex

  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Media
  alias Bordo.Posts
  alias Bordo.Posts.Post
  alias Bordo.Teams
  alias Bordo.Teams.Team
  alias Bordo.Users
  alias Bordo.Users.User
  alias BordoWeb.Helpers.BrandHelper
  alias BordoWeb.Live.AuthHelper

  def mount(params, session, socket) do
    {:ok, current_identity} = AuthHelper.load_user(session)
    current_user = Users.get_user!(current_identity.user_id)
    team = Teams.get_team!(current_identity.team_id)

    brands = fetch_brands(current_user.team_id)
    active_brand = Brands.get_brand!(slug: params["brand_slug"], preloads: [channels: :webhooks])

    {:ok,
     assign(socket,
       brands: brands,
       current_user: current_user,
       active_brand: active_brand,
       team: team,
       show_trial_banner: show_trial_banner?(team)
     )}
  end

  def handle_params(params, url, socket) do
    if BrandHelper.brand_configured?(socket.assigns.active_brand) do
      case socket.assigns.live_action do
        :composer -> handle_composer(params, url, socket)
        :launchpad -> {:noreply, socket}
        :schedule -> handle_schedule(params, url, socket)
        :media -> handle_media(params, url, socket)
        :settings -> handle_settings(params, url, socket)
        :team_settings -> handle_team_settings(params, url, socket)
      end
    else
      {:noreply, settings_assigns} = handle_team_settings(params, url, socket)

      if socket.assigns.live_action == :settings || socket.assigns.live_action == :team_settings do
        {:noreply, settings_assigns}
      else
        {:noreply,
         push_patch(socket,
           to:
             Routes.bordo_path(
               settings_assigns,
               :settings,
               socket.assigns.active_brand.slug
             )
         )}
      end
    end
  end

  def handle_composer(%{"id" => post_id}, _url, socket) do
    {:noreply, socket |> assign(post_id: post_id, team: socket.assigns.team)}
  end

  def handle_composer(_params, _url, socket) do
    {:noreply, socket |> assign(post_id: nil, team: socket.assigns.team)}
  end

  def handle_schedule(_params, _url, socket) do
    if BrandHelper.brand_configured?(socket.assigns.active_brand) do
      current_date = Timex.now() |> Timex.to_datetime(socket.assigns.team.timezone)

      assigns = [
        current_date: current_date,
        posts: [],
        show_slideover: false,
        current_user: socket.assigns.current_user
      ]

      {:noreply, socket |> assign(assigns)}
    else
      {:noreply,
       push_patch(socket,
         to: Routes.bordo_path(socket, :settings, socket.assigns.active_brand.slug)
       )}
    end
  end

  def handle_media(_params, _url, socket) do
    if BrandHelper.brand_configured?(socket.assigns.active_brand) do
      %{
        entries: entries,
        page_number: page_number,
        page_size: page_size,
        total_entries: total_entries,
        total_pages: total_pages
      } = Media.list_media(socket.assigns.active_brand.id)

      {:noreply,
       assign(socket,
         active_brand: socket.assigns.active_brand,
         medias: entries,
         show_slideover: false,
         search: "",
         page_number: page_number || 0,
         page_size: page_size || 0,
         total_entries: total_entries || 0,
         total_pages: total_pages || 0
       )}
    else
      {:noreply,
       push_patch(socket,
         to: Routes.bordo_path(socket, :settings, socket.assigns.active_brand.slug)
       )}
    end
  end

  def handle_settings(_params, _url, socket) do
    {:noreply, assign(socket, changeset: Brand.changeset(socket.assigns.active_brand, %{}))}
  end

  def handle_team_settings(_params, _url, socket) do
    users = Users.list_users_for_team(socket.assigns.active_brand.team_id)

    {:ok, payment_methods} =
      Stripe.PaymentMethod.list(%{customer: socket.assigns.team.stripe_customer_id, type: "card"})

    {:noreply,
     assign(socket,
       changeset: User.changeset(%User{}, %{}),
       team_changeset: Team.changeset(socket.assigns.team, %{}),
       users: users,
       payment_methods: payment_methods
     )}
  end

  def handle_event("acknowledge-trial", _params, socket) do
    Teams.update_team(socket.assigns.team, %{trial_banner_acknowledged_at: Timex.now()})
    {:noreply, socket |> assign(:show_trial_banner, false)}
  end

  def handle_event("canva-upload", %{"url" => url}, socket) do
    send(self(), {:upload, url})
    {:noreply, socket}
  end

  def handle_info({:upload, url}, socket) do
    {:ok, result} = Cloudex.upload([url], %{eager: "c_fit,w_800,h_800"})

    {:ok, media} =
      Media.create_media(%{
        "title" => result.original_filename,
        "public_id" => result.public_id,
        "url" => result.url,
        "thumbnail_url" => result.eager |> Enum.at(0) |> Map.get("url"),
        "bytes" => result.bytes,
        "width" => result.width,
        "height" => result.height,
        "resource_type" => "image",
        "brand_id" => socket.assigns.active_brand.id
      })

    send_update(BordoWeb.Media.UnsplashSearch, %{id: "unsplash-search", loading: false})

    {:noreply,
     socket
     |> put_flash(:success, "Uploaded #{result.original_filename}")
     |> assign(medias: socket.assigns.medias |> Enum.concat([media]))}
  end

  defp fetch_brands(team_id) do
    Brands.list_brands_for_team(team_id)
  end

  defp show_trial_banner?(%{
         is_paid_customer: is_paid_customer,
         trial_banner_acknowledged_at: trial_banner_acknowledged_at
       }) do
    if is_paid_customer do
      false
    else
      if is_nil(trial_banner_acknowledged_at) do
        true
      else
        false
      end
    end
  end

  defp show_trial_banner?(_team), do: false
end
