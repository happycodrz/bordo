defmodule BordoWeb.Helpers.Svg do
  use Phoenix.HTML

  alias BordoWeb.Router.Helpers, as: Routes

  def social_icon(name, opts \\ []) do
    classes = Keyword.get(opts, :class, "")
    styles = Keyword.get(opts, :style, "")

    content_tag(:img, "",
      src: Routes.static_path(BordoWeb.Endpoint, "/images/#{name}.svg"),
      class: classes,
      style: styles
    )
  end
end
