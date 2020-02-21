defmodule BordoWeb.FallbackController do
  @moduledoc """
  Centralised error handling for controllers
  """
  use BordoWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(BordoWeb.ErrorView)
    |> render(:"400", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(BordoWeb.ErrorView)
    |> render(:"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(BordoWeb.ErrorView)
    |> render(:"403")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BordoWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(BordoWeb.ErrorView)
    |> render(:"500")
  end
end
