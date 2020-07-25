# We probably eventually want to test the actual regex
defmodule Bordo.ContentParserTest do
  use Bordo.DataCase

  alias Bordo.ContentParser

  describe "parse/2 facebook" do
    test "text without links" do
      expected = [message: "text without links"]
      actual = ContentParser.parse(:facebook, "text without links")
      assert expected == actual
    end

    test "text with 1 link" do
      expected = [message: "text with links http://bor.do", link: "http://bor.do"]
      actual = ContentParser.parse(:facebook, "text with links http://bor.do")
      assert expected == actual
    end

    test "text with links" do
      expected = [message: "text with links http://bor.do https://bor.do", link: "http://bor.do"]
      actual = ContentParser.parse(:facebook, "text with links http://bor.do https://bor.do")
      assert expected == actual
    end
  end
end
