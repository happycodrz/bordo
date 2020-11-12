defmodule Bordo.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo
  alias Bordo.Teams.Team
  alias Stripe.{Customer, Subscription}
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic)
  end

  def subscribe(team_id) do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic <> "#{team_id}")
  end

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:team, :created])
    |> setup_stripe()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:team, :updated])
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    # TODO: Convert this to ecto-multi
    Bordo.Brands.list_brands_for_team(team.id)
    |> Enum.each(fn brand ->
      Bordo.Media.list_media(brand.id)
      |> Enum.each(fn media ->
        Bordo.Media.delete_media(media)
      end)

      Bordo.Brands.delete_brand(brand)
    end)

    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  def setup_stripe({:error, result}), do: {:error, result}

  def setup_stripe({:ok, result}) do
    team = get_team!(result.id) |> Repo.preload([:owner])

    with {:ok, resp} <-
           Customer.create(%{
             email: team.owner.email,
             metadata: %{team_id: result.id, team_name: result.name}
           }),
         {:ok, sub_resp} <-
           Subscription.create(%{
             customer: resp.id,
             items: [
               %{price: Application.fetch_env!(:bordo, :stripe)[:standard_price_id], quantity: 0}
             ]
           }) do
      update_team(team, %{stripe_customer_id: resp.id})
      update_team(team, %{stripe_subscription_id: sub_resp.id})

      {:ok, result}
    end
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
