defmodule BordoWeb.Helpers.Svg do
  use Phoenix.HTML

  alias BordoWeb.Router.Helpers, as: Routes

  def social_icon(name, opts \\ []) do
    classes = Keyword.get(opts, :class, "")
    styles = Keyword.get(opts, :style, "")

    content_tag(:svg, class: classes, style: styles) do
      tag(:use,
        "xlink:href": Routes.static_path(BordoWeb.Endpoint, "/images/social_icons.svg#" <> name)
      )
    end
  end
end
