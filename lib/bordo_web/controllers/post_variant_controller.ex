defmodule BordoWeb.PostVariantController do
  use BordoWeb, :controller

  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    post_variants = PostVariants.list_post_variants()
    render(conn, "index.json", post_variants: post_variants)
  end

  def create(conn, %{"post_variant" => post_variant_params}) do
    with {:ok, %PostVariant{} = post_variant} <- PostVariants.create_post_variant(post_variant_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.post_variant_path(conn, :show, post_variant))
      |> render("show.json", post_variant: post_variant)
    end
  end

  def show(conn, %{"id" => id}) do
    post_variant = PostVariants.get_post_variant!(id)
    render(conn, "show.json", post_variant: post_variant)
  end

  def update(conn, %{"id" => id, "post_variant" => post_variant_params}) do
    post_variant = PostVariants.get_post_variant!(id)

    with {:ok, %PostVariant{} = post_variant} <- PostVariants.update_post_variant(post_variant, post_variant_params) do
      render(conn, "show.json", post_variant: post_variant)
    end
  end

  def delete(conn, %{"id" => id}) do
    post_variant = PostVariants.get_post_variant!(id)

    with {:ok, %PostVariant{}} <- PostVariants.delete_post_variant(post_variant) do
      send_resp(conn, :no_content, "")
    end
  end
end
