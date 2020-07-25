defmodule Bordo.ContentParser do
  @url_regex ~r/(https?+\:\/\/)?([\w\d-]+\.)*[\w-]+[\.\:]\w+([\/\.\?\=\&\#]?[\w-]+)*\/?/

  def parse(:facebook, content) do
    links =
      @url_regex
      |> Regex.scan(content)

    if Enum.any?(links) do
      [message: content, link: links |> Enum.at(0) |> Enum.at(0)]
    else
      [message: content]
    end
  end
end
