defmodule BordoWeb.Admin.SharedView do
  import Phoenix.HTML

  def brand_avatar(url) do
    url =
      if is_nil(url) do
        "https://res.cloudinary.com/bordo/image/upload/v1589196836/bordo-logo_1x_jsyhqi.jpg"
      end

    ~e"""
    <img
      class="h-12 w-12 rounded-full"
      src="<%= url %>"
      alt=""
    />
    """
  end

  def feather_icon(name, class \\ "") do
    ~e"""
    <svg class="feather <%= class %>">
      <use xlink:href="<%= BordoWeb.Router.Helpers.static_path(BordoWeb.Endpoint, "/images/feather-sprite.svg#"<> name) %>"/>
    </svg>
    """
  end

  def friendly_time_tag(naive_datetime) do
    ~e"""
      <time datetime="<%= Timex.format!(naive_datetime, "%Y-%m-%d", :strftime) %>" class="ml-1"><%= friendly_time(naive_datetime)%></time>
    """
  end

  def friendly_time(naive_datetime) do
    Timex.format!(naive_datetime, "%B %e, %Y at %H:%M UTC", :strftime)
  end
end
