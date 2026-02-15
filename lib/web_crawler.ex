defmodule WebCrawler do
  @moduledoc """
  Entry point for crawlin'
  """

  def crawl(url) do
    uri = URI.new!(url)

    [uri]
    |> crawl([])
    |> Enum.map(&URI.to_string/1)
    |> Enum.frequencies()
  end

  # If no more to visit, return visited!
  defp crawl([], visited) do
    visited
  end

  defp crawl([visit | rest], visited) do
    # If URI to visit is a member of visited, bypass it
    if visit in visited do
      crawl(rest, visited)
    else
      # Otherwise, visit the URL
      %Req.Response{body: body} = Req.get!(Req.new(url: visit))
      visited = [visit | visited]

      new_anchor_uris =
        body
        |> Floki.parse_document!()
        |> Floki.find("a[href]")
        |> Enum.map(&Floki.attribute(&1, "href"))
        |> Enum.map(&hd/1)
        |> Enum.map(&URI.merge(visit, &1))
        |> Enum.reject(&(&1.host != visit.host))

      # Add whatever uris were found to URIs to visit and keep going!
      crawl(rest ++ new_anchor_uris, visited)
    end
  end
end
