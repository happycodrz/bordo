defmodule BordoWeb.Helpers.TimeHelper do
  alias Timex.Timezone

  def current_time(timezone) do
    Timex.now()
    |> Timezone.convert(timezone)
    |> Timex.format!("%b %d, %Y at %I:%M %p", :strftime)
  end
end
