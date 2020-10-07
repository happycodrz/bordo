defmodule BordoWeb.Helpers.BrandHelper do
  alias Bordo.Brands.Brand

  def brand_letters(%Brand{name: name}) do
    letters =
      name
      |> String.split(" ")
      |> Enum.map(fn x -> x |> String.graphemes() |> Enum.at(0) end)

    if length(letters) > 2 do
      Enum.join([Enum.at(letters, 0), Enum.at(letters, -1)])
    else
      Enum.join(letters)
    end
  end

  def brand_configured?(%Brand{channels: channels}) do
    Enum.any?(channels)
  end
end
