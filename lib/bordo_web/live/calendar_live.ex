defmodule BordoWeb.CalendarLive do
  use BordoWeb, :live_component
  use Timex

  alias Bordo.Posts

  @week_start_at :sun

  def preload(list_of_assigns) do
    a = list_of_assigns |> Enum.at(0)
    posts = fetch_posts(a.active_brand.id, a.current_date)
    mapped_posts = mapped_posts(posts, week_rows(a.current_date))

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :posts, mapped_posts)
    end)
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
end
