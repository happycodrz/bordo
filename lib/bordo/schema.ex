defmodule Bordo.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def generate_short_slug() do
    Ecto.UUID.generate() |> String.split("-") |> Enum.at(0)
  end
end
