defmodule BordoWeb.LaunchpadView do
  @moduledoc false
  use BordoWeb, :view

  alias BordoWeb.Helpers.BrandHelper

  defp greeting do
    Enum.random([
      "Hello",
      "Welcome back",
      "Howdy",
      "What's up",
      "Hola",
      "Sup",
      "Hey",
      "Hey there"
    ])
  end

  defp user_greeting(%{email: email, first_name: first_name}) do
    first_name || email
  end
end
