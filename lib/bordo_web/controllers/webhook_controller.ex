defmodule BordoWeb.WebhookController do
  use BordoWeb, :controller

  alias Bordo.Repo
  alias Bordo.Teams
  alias Bordo.Teams.Team

  action_fallback BordoWeb.FallbackController

  @doc """
  Stripe hook for customer.subscription.updated
  Used to update the last_paid_at on a team
  """
  def hook(conn, %{"type" => "customer.subscription.updated"} = params),
    do: update_last_paid_at(conn, params)

  defp update_last_paid_at(conn, params) do
    %{"data" => %{"object" => %{"customer" => customer_id}}} = params

    team = Repo.get_by(Team, stripe_customer_id: customer_id)

    if is_nil(team) do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: %{detail: "customer does not exist or is not tied to a team"}})
    else
      Teams.update_team(team, %{last_paid_at: Timex.now()})

      conn
      |> put_status(:ok)
      |> json(%{})
    end
  end
end
