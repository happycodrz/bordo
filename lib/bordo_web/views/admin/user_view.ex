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

  def full_name(user) do
    try do
      user.first_name <> " " <> user.last_name
    after
      "unknown"
    end
  end
end
