defmodule BordoWeb.Components.CalendarDay do
  use BordoWeb, :live_component
  use Timex
  alias BordoWeb.Helpers.Svg

  def render(assigns) do
    assigns = Map.put(assigns, :day_class, day_class(assigns))

    ~L"""
    <div phx-click="pick-date" phx-value-date="<%= Timex.format!(@day, "%Y-%m-%d", :strftime) %>" class="<%= @day_class %>">
      <sup><%= Timex.format!(@day, "%e", :strftime) %></sup>
      <%= for post <- @posts do %>
        <%= calendar_day_post(@socket, post) %>
      <% end %>
      </div>
    """
  end

  defp day_class(assigns) do
    cond do
      today?(assigns) ->
        "calendar__day calendar__day--today"

      current_date?(assigns) ->
        "calendar__day"

      other_month?(assigns) ->
        "calendar__day"

      true ->
        "calendar__day"
    end
  end

  defp calendar_day_post(socket, post) do
    time = Timex.to_datetime(post.scheduled_for, "America/Chicago")

    scheduled_for =
      Timex.format!(time, "%H:%M", :strftime) <>
        String.downcase(Timex.format!(time, "%p", :strftime))

    networks = post.post_variants |> Enum.map(& &1.channel.network)
    assigns = %{socket: socket}

    ~L"""
      <div class="<%= post_css(post) %>" phx-click="open-slideover" phx-target="#new-post" phx-value-post_id="<%= post.id %>">
        <div class="flex items-center justify-between mb-1">
          <span class="text-truncate pr-1"><%= post.title %></span><span><%= scheduled_for %></span>
        </div>
        <div class="flex items-center">
          <span class="flex">
            <%= for network <- networks do %>
              <%= social_logo(network) %>
            <% end %>
          </span>
        </div>
      </div>
    """
  end

  defp social_logo("twitter") do
    Svg.social_icon("twitter_white",
      class: "fill-current text-white mr-1",
      style: "width: 10px; height: 10px;"
    )
  end

  defp social_logo("linkedin") do
    Svg.social_icon("linkedin_white",
      class: "fill-current text-white mr-1",
      style: "width: 10px; height: 10px;"
    )
  end

  defp social_logo("facebook") do
    Svg.social_icon("fb_white",
      class: "fill-current text-white mr-1",
      style: "width: 10px; height: 10px;"
    )
  end

  defp current_date?(assigns) do
    Map.take(assigns.day, [:year, :month, :day]) ==
      Map.take(assigns.current_date, [:year, :month, :day])
  end

  defp today?(assigns) do
    Map.take(assigns.day, [:year, :month, :day]) == Map.take(Timex.now(), [:year, :month, :day])
  end

  defp other_month?(assigns) do
    Map.take(assigns.day, [:year, :month]) != Map.take(assigns.current_date, [:year, :month])
  end

  def post_css(post) do
    failed =
      post.post_variants |> Enum.map(fn pv -> pv.status end) |> Enum.filter(&(&1 == "failed"))

    main_css =
      case Timex.compare(Timex.now(), post.scheduled_for) do
        1 ->
          "bdo-scheduleCalendar__post bdo-scheduleCalendar__post--past"

        _ ->
          "bdo-scheduleCalendar__post"
      end

    if Enum.any?(failed) do
      main_css <> " bdo-scheduleCalendar__post--attention"
    else
      main_css
    end
  end
end
