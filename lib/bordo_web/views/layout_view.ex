defmodule BordoWeb.LayoutView do
  use BordoWeb, :view

  import Phoenix.LiveView, only: [send_update: 2]

  @doc """
  Sends a message to the toast component if the flash message is supported
  """
  def render_flash(flash) do
    any_flash = ((flash |> Map.keys()) -- ["error", "success", "info"]) |> Enum.empty?()

    if any_flash && Enum.any?(flash) do
      send_update(BordoWeb.Components.Toast,
        id: "toast",
        show: true,
        type: :success,
        message: message_list(flash |> Map.values())
      )

      nil
    else
      nil
    end
  end

  defp message_list(message) when is_binary(message), do: message
  defp message_list(message) when is_list(message), do: message |> List.flatten()

  @doc """
  Returns the string in the 3rd argument if the expected controller
  matches the Phoenix controller that is extracted from conn. If no 3rd
  argument is passed in then it defaults to "active".

  The 2nd argument can also be an array of controllers that should
  return the active class.
  """
  def active_link(conn, controllers) when is_list(controllers) do
    cond do
      Map.has_key?(conn.assigns, :phoenix_controller) ->
        if Enum.member?(controllers, Phoenix.Controller.controller_module(conn)) do
          active_class()
        else
          default_class()
        end

      Map.has_key?(conn.assigns, :live_module) ->
        if Enum.member?(controllers, conn.assigns.live_module) do
          active_class()
        else
          default_class()
        end

      true ->
        default_class()
    end
  end

  def active_link(conn, controllers), do: active_link(conn, [controllers])

  defp default_class do
    "ml-4 px-3 py-2 rounded-md text-sm font-medium text-gray-300 hover:text-white hover:bg-gray-700 focus:outline-none focus:text-white focus:bg-gray-700"
  end

  defp active_class do
    "px-3 py-2 ml-4 rounded-md text-sm font-medium text-white bg-gray-900 focus:outline-none focus:text-white focus:bg-gray-700"
  end
end
