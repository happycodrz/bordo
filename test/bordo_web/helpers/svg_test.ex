defmodule BordoWeb.Helpers.SvgTest do
  use BordoWeb.ConnCase, async: true
  import Phoenix.HTML, only: [safe_to_string: 1, sigil_e: 2]
  alias BordoWeb.Helpers.Svg

  test "social_icon/2 renders a svg icon" do
    image =
      Svg.social_icon("active", class: "something")
      |> safe_to_string()

    assert image ==
             ~e"""
             <svg class="something" style=""><use xlink:href="/images/social_icons.svg#active"></svg>
             """
             |> safe_to_string()
             |> String.trim()
  end
end
