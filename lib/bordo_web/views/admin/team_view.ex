defmodule BordoWeb.Admin.TeamView do
  use BordoWeb, :view
  import Phoenix.HTML

  def payment_status(team) do
    if is_nil(team.last_paid_at) do
      payment_not_current(team.last_paid_at)
    else
      first_payment = Timex.now()
      diff = Timex.compare(team.last_paid_at, first_payment, :day)

      if diff <= 0 do
        payment_not_current(team.last_paid_at)
      else
        payment_current(team.last_paid_at)
      end
    end
  end

  defp payment_current(last_paid_at) do
    ~e"""
      <div class="px-2 inline-flex items-center text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
        Active
        <i data-feather="check-circle" class="text-green-800 ml-1" width="12" phx-hook="FeatherIcon"></i>
      </div>
      <div class="text-sm leading-5 text-gray-500">Last paid: <%= Timex.format!(last_paid_at, "%Y-%m-%d", :strftime) %></div>
    """
  end

  defp payment_not_current(last_paid_at) when is_nil(last_paid_at) do
    ~e"""
      <div class="px-2 inline-flex items-center text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
        Never Paid
        <i data-feather="alert-circle" class="text-red-800 ml-1" width="12" phx-hook="FeatherIcon"></i>
      </div>
    """
  end

  defp payment_not_current(last_paid_at) do
    ~e"""
      <div class="px-2 inline-flex items-center text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
        Not Current
        <i data-feather="alert-circle" class="text-red-800 ml-1" width="12" phx-hook="FeatherIcon"></i>
      </div>
      <div class="text-sm leading-5 text-gray-500">Last paid: <%= Timex.format!(last_paid_at, "%Y-%m-%d", :strftime) %></div>
    """
  end
end
