defmodule Auth.CurrentBrand do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{current_identity: _current_identity}} = conn, _default) do
    IO.inspect("ASSIGNING CURRENT BRAND")
    assign(conn, :current_brand, 1)
  end
end
