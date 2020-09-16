defmodule BordoWeb.Helpers.BrandHelper do
  alias Bordo.Brands.Brand

  def brand_letters(%Brand{name: name}) do
    name
    |> String.split(" ")
    |> Enum.map(fn x -> x |> String.graphemes() |> Enum.at(0) end)
    |> Enum.join()
  end
end
