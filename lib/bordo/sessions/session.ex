defmodule Bordo.Sessions.Session do
  @moduledoc """
  Used to store a session, which will be a salted uuid for the user_id.
  """
  use Bordo.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :session_id, :binary_id
    field :token, :string
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:session_id, :token])
  end
end
