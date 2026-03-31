defmodule WebCrawler do
  @moduledoc """
  Entry point for crawlin'

  https://crawler-test.com/
  """

  def crawl(url) do
    uri = URI.new!(url)

    {sync_time, sync_result} =
      :timer.tc(fn ->
        [uri]
        |> crawl([])
        |> Enum.map(&URI.to_string/1)
        |> Enum.frequencies()
      end)

    {concurrent_time, concurrent_results} =
      :timer.tc(fn ->
        [uri]
        |> crawl([], concurrent: true)
        |> Enum.map(&URI.to_string/1)
        |> Enum.frequencies()
      end)

    %{
      sync_time: sync_time / 1_000_000,
      sync_result: sync_result,
      concurrent_time: concurrent_time / 1_000_000,
      concurrent_results: concurrent_results
    }
  end

  # If no more to visit, return visited!
  defp crawl(visit, visited, opts \\ [concurrent: false])

  defp crawl([], visited, _opts) do
    visited
  end

  defp crawl([visit | rest], visited, concurrent: false) do
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

  defp crawl(visit, visited, opts) do
    uris_to_visit = Enum.reject(visit, &(&1 in visited))

    requests =
      for uri <- uris_to_visit do
        Task.async(fn ->
          %Req.Response{body: body} = Req.get!(Req.new(url: uri))

          body
          |> Floki.parse_document!()
          |> Floki.find("a[href]")
          |> Enum.map(&Floki.attribute(&1, "href"))
          |> Enum.map(&hd/1)
          |> Enum.map(&URI.merge(uri, &1))
          |> Enum.reject(&(&1.host != uri.host))
        end)
      end

    new_anchor_uris = requests |> Task.await_many() |> List.flatten()

    crawl(new_anchor_uris, uris_to_visit ++ visited, opts)
  end
end
