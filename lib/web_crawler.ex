defmodule WebCrawler do
  @moduledoc """
  Entry point for crawlin'
  """

  def crawl(url) do
    uri = URI.new!(url)

    uri
    |> crawl([])
    |> Enum.map(&URI.to_string/1)
    |> Enum.frequencies()
  end

  defp crawl(uri, visited) do
    %Req.Response{body: body} = Req.new(url: uri) |> Req.get!()
    visited = [uri | visited]

    found =
      body
      |> Floki.parse_document!()
      |> Floki.find("a[href]")
      |> Enum.map(&Floki.attribute(&1, "href"))
      |> Enum.map(&hd/1)
      |> Enum.map(&URI.merge(uri, &1))
      |> Enum.reject(&(&1.host != uri.host))
      |> Enum.reject(&Enum.member?(visited, &1))
      # Change the recursion somehow so that we add the results of the crawling to the visited for the next call
      |> Enum.map(&crawl(&1, visited))
      |> List.flatten()

    [uri | found]
  end
end
