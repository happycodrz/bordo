defmodule DateHelper do
  def local_date(date) do
    Timex.format!(date, "%B %d, %Y", :strftime)
  end
end
