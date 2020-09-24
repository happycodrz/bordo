defmodule BordoWeb.Components.CalendarDay do
  use BordoWeb, :live_component
  use Timex
  alias BordoWeb.Helpers.Svg

  def render(assigns) do
    assigns = Map.put(assigns, :day_class, day_class(assigns))

    ~L"""
    <div phx-click="pick-date" phx-value-date="<%= Timex.format!(@day, "%Y-%m-%d", :strftime) %>" class="border-b border-r border-gray-200 px-3 py-2 h-40 flex flex-col items-baseline">
      <span class="inline-flex items-center -ml-2 px-2 py-1 rounded-full text-sm font-light text-gray-600 leading-5 <%= @day_class %>">
        <%= Timex.format!(@day, "%e", :strftime) %>
      </span>
      <div class="overflow-y-auto mt-2 w-full">
        <%= for post <- @posts do %>
          <%= calendar_day_post(@socket, post) %>
        <% end %>
      </div>
    </div>
    """
  end

  defp day_class(assigns) do
    cond do
      today?(assigns) ->
        "bg-blue-100 text-blue-800"

      current_date?(assigns) ->
        ""

      other_month?(assigns) ->
        ""

      true ->
        ""
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
    <div phx-click="open-slideover" phx-target="#new-post" phx-value-post_id="<%= post.id %>" class="group cursor-pointer flex items-center justify-between px-2.5 py-0.5 rounded-md text-sm font-medium leading-5 mb-2 transition ease-in-out duration-100 <%= post_css(post) %>">
        <span class="flex items-center truncate ">
          <%= post.title %>
        </span>
        <span class="text-xs <%= time_css(post) %>">
          <%= scheduled_for %>
        </span>
    </div>
    """
    # <%= for network <- networks do %>
    #   <%= social_logo(network) %>
    # <% end %>
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
          "bg-gray-100 hover:bg-gray-50 text-gray-600 hover:text-gray-500"

        _ ->
          "bg-blue-200 text-blue-800 hover:bg-blue-100 hover:text-blue-700"
      end

    if Enum.any?(failed) do
      main_css = "bg-red-200 text-red-600 hover:bg-red-100 group-hover:text-red-500"
    else
      main_css
    end
  end

  def time_css(post) do
    failed =
      post.post_variants |> Enum.map(fn pv -> pv.status end) |> Enum.filter(&(&1 == "failed"))

    main_css =
      case Timex.compare(Timex.now(), post.scheduled_for) do
        1 ->
          "text-gray-400 text-xs"

        _ ->
          "text-blue-600"
      end

    if Enum.any?(failed) do
      main_css <> "text-red-500 group-hover:text-red-400"
    else
      main_css
    end
  end
end
