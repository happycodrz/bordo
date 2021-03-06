defmodule BordoWeb.Admin.TeamView do
  use BordoWeb, :view
  import Phoenix.HTML

  def trialing_tag(team) do
    two_weeks_ago = Timex.subtract(Timex.now(), Timex.Duration.from_weeks(2))
    diff = Timex.compare(team.inserted_at, two_weeks_ago)

    if diff == 1 do
      ~e"""
        <span class="text-xs text-gray-500"> Trialing</span>
      """
    end
  end

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
        <%= feather_icon("check-circle", "text-green-800 ml-1") %>
      </div>
      <div class="text-sm leading-5 text-gray-500">Last paid: <%= Timex.format!(last_paid_at, "%Y-%m-%d", :strftime) %></div>
    """
  end

  defp payment_not_current(last_paid_at) when is_nil(last_paid_at) do
    ~e"""
      <div class="px-2 inline-flex items-center text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
        Never Paid
        <%= feather_icon("alert-circle", "text-red-800 ml-1") %>
      </div>
    """
  end

  defp payment_not_current(last_paid_at) do
    ~e"""
      <div class="px-2 inline-flex items-center text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
        Not Current
        <%= feather_icon("alert-circle", "text-red-800 ml-1") %>
      </div>
      <div class="text-sm leading-5 text-gray-500">Last paid: <%= Timex.format!(last_paid_at, "%Y-%m-%d", :strftime) %></div>
    """
  end
end
