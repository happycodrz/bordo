defmodule BordoWeb.Admin.PostView do
  use BordoWeb, :view

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
end
