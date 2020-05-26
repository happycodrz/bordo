defmodule BordoWeb.Admin.PostView do
  use BordoWeb, :view

  def filter_tab(text, link, status) do
    ~e"""
    <div class="<%= filter_tab_class(text, status) %>">
      <%= live_patch to: link do %>
      <dt class="order-2 mt-1 text-lg leading-6 font-medium" id="item-1">
        <%= text %>
      </dt>
      <% end %>
    </div>
    """
  end

  def table_network_cluster(post_variants) when is_list(post_variants) do
    Enum.map(post_variants, fn variant -> feather_icon(variant.channel.network) end)
  end

  def table_status(post_variants, scheduled_for) when is_list(post_variants) do
    statuses = Enum.map(post_variants, fn pv -> pv.status end)

    cond do
      Enum.member?(statuses, "failed") ->
        ~e"""
        <div class="flex items-center text-sm leading-5 text-gray-500">
          <%= feather_icon("alert-circle", "h5 w-5 mr-1.5 text-red-400") %>
          One or more integrations failed
        </div>
        """

      Enum.member?(statuses, "scheduled") ->
        ~e"""
        <div class="flex items-center text-sm text-gray-500">
          <%= feather_icon("calendar", "h5 w-5 mr-1.5") %>
          Scheduled for <%= friendly_time_tag(scheduled_for) %>
        </div>
        """

      true ->
        ~e"""
        <div class="flex items-center text-sm text-gray-500">
          <%= feather_icon("check-circle", "h5 w-5 mr-1.5 text-green-400") %>

          Published on <%= friendly_time_tag(scheduled_for) %>
        </div>
        """
    end
  end

  defp filter_tab_class(text, status) do
    text_status = String.downcase(text)

    default_css =
      "flex flex-col border-b gray-indigo-100 p-3 text-center text-gray-400 sm:border-0 sm:border-r"

    selected_css =
      "flex flex-col text-indigo-900 border-b gray-indigo-100 p-3 text-center sm:border-0 sm:border-r"

    cond do
      text_status == status ->
        selected_css

      status == nil && text_status == "all" ->
        selected_css

      true ->
        default_css
    end
  end
end
