defmodule Bordo.Schema do
  def generate_short_uuid() do
    Ecto.UUID.generate() |> String.split("-") |> Enum.at(0)
  end
end
