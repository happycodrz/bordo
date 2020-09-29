defmodule BordoWeb.Helpers.TimeHelper do
  alias Timex.Timezone

  def current_time(timezone) do
    Timex.now()
    |> Timezone.convert(timezone)
    |> Timex.format!("%b %d, %Y at %I:%M %p", :strftime)
  end

  def local_date(date) do
    Timex.format!(date, "%B %d, %Y", :strftime)
  end
end
