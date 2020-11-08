defmodule BordoWeb.FormHelper do
  import Phoenix.HTML, only: [sigil_e: 2]
  import Phoenix.HTML.Form, only: [select: 4]

  def timezone_select(form, field, selected) do
    ~e"""
      <%= select form, field, friendly_timezone_list(), selected: selected, class: "mt-1 form-select block w-full pl-3 pr-10 py-2 text-base leading-6 border-gray-300 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5" %>
    """
  end

  # A short list of US timezones
  # For now, we can just manually build a list of the continental US
  defp friendly_timezone_list do
    # Tzdata.zone_lists_grouped().northamerica
    [
      {"Eastern", "America/New_York"},
      {"Central", "America/Chicago"},
      {"Mountain", "America/Denver"},
      {"Pacific", "America/Los_Angeles"}
    ]
  end
end
