defmodule StripeApiMock do
  @moduledoc """
  This mock replaces calls to the stripe-api from stripity_stripe.
  """
  def request(:post, "https://api.stripe.com/v1/customers", _, _, _) do
    {:ok, 200, [], File.read!("test/fixtures/stripe/new_customer.json")}
  end

  def request(:post, "https://api.stripe.com/v1/subscriptions", _, _, _) do
    {:ok, 200, [], File.read!("test/fixtures/stripe/new_subscription.json")}
  end

  def request(:get, "https://api.stripe.com/v1/subscriptions/sub_stripe_id", _, _, _) do
    {:ok, 200, [], File.read!("test/fixtures/stripe/subscription.json")}
  end

  def request(:post, "https://api.stripe.com/v1/subscriptions/sub_stripe_id", _, _, _) do
    {:ok, 200, [], "{}"}
  end
end
