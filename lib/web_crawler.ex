defmodule WebCrawler do
  @moduledoc """
  Entry point for crawlin'

  https://crawler-test.com/
  """

  def crawl(url, opts \\ []) do
    uri = URI.new!(url)

    max_depth = Keyword.get(opts, :max_depth, :infinity)

    context = %{
      current_depth: 0,
      max_depth: max_depth
    }

    [uri]
    |> crawl([], context)
    |> Enum.map(&URI.to_string/1)
    |> Enum.frequencies()
  end

  # If no more to visit, return visited!
  defp crawl(visit, visited, context)

  defp crawl([], visited, _opts) do
    visited
  end

  defp crawl(visit, visited, %{current_depth: max_depth, max_depth: max_depth}) do
    visit ++ visited
  end

  defp crawl(visit, visited, context) do
    %{current_depth: current_depth} = context

    requests =
      for uri <- visit do
        Task.async(fn ->
          %Req.Response{body: body} = Req.get!(Req.new(url: uri))

          body
          |> Floki.parse_document!()
          |> Floki.find("a[href]")
          |> Enum.map(&Floki.attribute(&1, "href"))
          |> Enum.map(&hd/1)
          |> Enum.map(&String.replace_suffix(&1, "/", ""))
          |> Enum.map(&URI.merge(uri, &1))
          |> Enum.reject(&(&1.host != uri.host))
        end)
      end

    visited = visit ++ visited

    uris_to_visit =
      requests
      |> Task.await_many()
      |> List.flatten()
      |> Enum.reject(&(&1 in visited))

    new_context = %{context | current_depth: current_depth + 1}
    crawl(uris_to_visit, visited, new_context)
  end
end
