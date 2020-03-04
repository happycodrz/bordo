defmodule Auth.Identity do
  @moduledoc """
  This struct represents the Identitiy accessible on each connection
  It contains an id(auth0 id) and a user_id.
  """
  @enforce_keys [:id, :user_id]
  defstruct id: nil, user_id: nil

  @type t() :: [
          id: String.t(),
          user_id: String.t()
        ]
end
