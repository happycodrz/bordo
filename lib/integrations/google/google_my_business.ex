defmodule GoogleMyBusiness do
  @doc """
  List all accounts for a token
  """
  def list_accounts(token) do
    HTTPoison.get!("https://mybusiness.googleapis.com/v4/accounts",
      Authorization: "Bearer: #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end

  @doc """
  List account information
  """
  def get_account!(token, account_id) do
    HTTPoison.get!("https://mybusiness.googleapis.com/v4/accounts/#{account_id}",
      Authorization: "Bearer: #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
