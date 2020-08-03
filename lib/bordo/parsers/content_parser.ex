defmodule Bordo.ContentParser do
  def parse(:facebook, content) do
    [message: content, links: parse_links(content)]
  end

  def parse(:linkedin, content) do
    [message: content, links: parse_links(content)]
  end

  defp parse_links(content) do
    for s <- String.split(content), u = URI.parse(s), u.host != nil, do: s
  end
end
