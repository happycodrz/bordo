# We probably eventually want to test the actual regex
defmodule Bordo.ContentParserTest do
  use Bordo.DataCase

  alias Bordo.ContentParser

  describe "parse/2 facebook" do
    test "text without links" do
      expected = [message: "text without links", links: []]
      actual = ContentParser.parse(:facebook, "text without links")
      assert expected == actual
    end

    test "text with 1 link" do
      expected = [message: "text with links http://bor.do", links: ["http://bor.do"]]
      actual = ContentParser.parse(:facebook, "text with links http://bor.do")
      assert expected == actual
    end

    test "text with links" do
      expected = [
        message: "text with links http://bor.do https://bor.do",
        links: ["http://bor.do", "https://bor.do"]
      ]

      actual = ContentParser.parse(:facebook, "text with links http://bor.do https://bor.do")
      assert expected == actual
    end

    test "long links" do
      expected = [
        message: "https://bor.do/things/more-things.html",
        links: ["https://bor.do/things/more-things.html"]
      ]

      actual = ContentParser.parse(:facebook, "https://bor.do/things/more-things.html")
      assert expected == actual
    end
  end

  describe "parse/2 linkedin" do
    test "text with 1 link" do
      expected = [message: "text with links http://www.bor.do", links: ["http://www.bor.do"]]
      actual = ContentParser.parse(:facebook, "text with links http://www.bor.do")
      assert expected == actual
    end
  end
end
