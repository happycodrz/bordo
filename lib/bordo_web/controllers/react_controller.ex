defmodule BordoWeb.ReactController do
  use BordoWeb, :controller

  action_fallback BordoWeb.FallbackController

  @doc """
  Stripe hook for customer.subscription.updated
  Used to update the last_paid_at on a team
  """
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
