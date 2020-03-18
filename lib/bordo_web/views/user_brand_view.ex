defmodule BordoWeb.UserBrandView do
  use BordoWeb, :view

  def render("show.json", %{user_brand: user_brand}) do
    %{id: user_brand.id, user_id: user_brand.user_id, brand_id: user_brand.id}
  end
end
