defmodule BordoWeb.Admin.UserView do
  use BordoWeb, :view

  def avatar(%{image_url: image_url}) when is_binary(image_url) do
    image_url
  end

  def avatar(%{email: email, image_url: image_url}) when is_nil(image_url) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    default = "mm"
    "https://www.gravatar.com/avatar/" <> hash <> "?d=" <> default
  end

  def team_name(team) when is_nil(team), do: "unassigned"
  def team_name(%{name: name}), do: name

  def full_name(%{first_name: first_name, last_name: last_name})
      when is_nil(first_name)
      when is_nil(last_name) do
    "unknown"
  end

  def full_name(%{first_name: first_name, last_name: last_name}) do
    [first_name, last_name] |> Enum.reject(&(&1 == "" || is_nil(&1))) |> Enum.join(" ")
  end

  def active_tag(%{auth0_id: auth0_id}) do
    if is_nil(auth0_id) do
      ~e"""
      <span
        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800"
      >
        Auth0 not connected
      </span>
      """
    else
      ~e"""
      <span
        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800"
      >
        Auth0 connected
      </span>
      """
    end
  end
end
