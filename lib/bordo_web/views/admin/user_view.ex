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

  def full_name(%{first_name: first_name, last_name: last_name})
      when is_nil(first_name)
      when is_nil(last_name) do
    "unknown"
  end

  def full_name(%{first_name: first_name, last_name: last_name}) do
    [first_name, last_name] |> Enum.reject(&(&1 == "" || is_nil(&1))) |> Enum.join(" ")
  end

  # def full_name(%{first_name: first_name, last_name: last_name}) do
  #   try do
  #     user.first_name <> " " <> user.last_name
  #   after
  #     "unknown"
  #   end
  # end
end
