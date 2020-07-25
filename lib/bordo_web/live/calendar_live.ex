defmodule BordoWeb.CalendarLive do
  use BordoWeb, :client_live_view
  use Timex

  alias Bordo.Brands
  alias Bordo.Posts
  alias Ecto.Changeset

  @week_start_at :sun

  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)
    current_date = Timex.now()
    posts = fetch_posts(active_brand.id, current_date)
    week_rows = week_rows(current_date)
    mapped_posts = mapped_posts(posts, week_rows)

    assigns = [
      current_date: current_date,
      day_names: day_names(@week_start_at),
      week_rows: week_rows,
      active_brand: active_brand,
      nav_item: "schedule",
      posts: mapped_posts,
      show_slideover: false
    ]

    {:ok, assign(socket, assigns)}
  end

  defp day_names(:sun), do: [7, 1, 2, 3, 4, 5, 6] |> Enum.map(&Timex.day_name/1)
  defp day_names(_), do: 1..7 |> Enum.map(&Timex.day_name/1)

  defp week_rows(current_date) do
    first =
      current_date
      |> Timex.beginning_of_month()
      |> Timex.beginning_of_week(@week_start_at)

    last =
      current_date
      |> Timex.end_of_month()
      |> Timex.end_of_week(@week_start_at)

    Interval.new(from: first, until: last)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
  end

  defp fetch_posts(brand_id, current_date) do
    config = Posts.filter_options(:brand_index)
    {:ok, start_date} = Timex.format(Timex.beginning_of_month(current_date), "{ISO:Extended:Z}")
    {:ok, end_date} = Timex.format(Timex.end_of_month(current_date), "{ISO:Extended:Z}")

    case Filtrex.parse_params(config, %{
           "scheduled_for_after" => start_date,
           "scheduled_for_before" => end_date
         }) do
      {:ok, filter} ->
        Posts.list_posts(brand_id, filter)

      {:error, _error} ->
        []
    end
  end

  defp mapped_posts(posts, week_rows) do
    days_of_month = Enum.flat_map(week_rows, fn week -> Enum.map(week, fn day -> day end) end)

    days_of_month
    |> Enum.into(%{}, fn day ->
      {day,
       Enum.filter(posts, fn post ->
         Timex.compare(Timex.to_date(day), Timex.to_naive_datetime(post.scheduled_for), :day) == 0
       end)}
    end)
  end

  def handle_event("prev-month", _, socket) do
    current_date = Timex.shift(socket.assigns.current_date, months: -1)
    posts = fetch_posts(socket.assigns.active_brand.id, current_date)
    week_rows = week_rows(current_date)
    mapped_posts = mapped_posts(posts, week_rows)

    assigns = [
      current_date: current_date,
      week_rows: week_rows(current_date),
      posts: mapped_posts
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("next-month", _, socket) do
    current_date = Timex.shift(socket.assigns.current_date, months: 1)
    posts = fetch_posts(socket.assigns.active_brand.id, current_date)
    week_rows = week_rows(current_date)
    mapped_posts = mapped_posts(posts, week_rows)

    assigns = [
      current_date: current_date,
      week_rows: week_rows(current_date),
      posts: mapped_posts
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("pick-date", %{"date" => date}, socket) do
    current_date = Timex.parse!(date, "{YYYY}-{0M}-{D}")

    assigns = [
      current_date: current_date
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("dispatch-edit-state", %{"post_id" => post_id}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         Routes.live_path(
           socket,
           BordoWeb.CalendarLive,
           socket.assigns.active_brand.slug,
           post_id
         )
     )}
  end

  def handle_event("close-slideover", _params, socket) do
    {
      :noreply,
      socket
      |> push_patch(
        to: Routes.live_path(socket, BordoWeb.CalendarLive, socket.assigns.active_brand.slug)
      )
    }
  end

  def handle_params(%{"post_id" => post_id}, _uri, socket) do
    post = Posts.get_post!(post_id)

    changeset =
      Posts.change_post(post)
      |> Changeset.put_assoc(
        :post_variants,
        post.post_variants
        |> Enum.map(fn pv ->
          if pv.post_variant_media |> Enum.empty?() do
            pv |> Changeset.change(post_variant_media: [%{media_id: nil}])
          else
            pv
          end
        end)
      )

    {:noreply,
     socket
     |> assign(:show_slideover, true)
     |> assign(:post, post)
     |> assign(:changeset, changeset)
     |> assign(:active_brand, socket.assigns.active_brand)}
  end

  def handle_params(_, _uri, socket) do
    {:noreply, socket |> assign(:show_slideover, false)}
  end
end
