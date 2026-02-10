defmodule WebCrawler do
  @moduledoc """
  Entry point for crawlin'
  """

  def crawl(url, _visited \\ []) do
    uri = URI.new!(url) |> dbg(label: :parsed)

    %Req.Response{body: body} = Req.new(url: uri) |> Req.get!() |> dbg(label: :response)

    body
    |> Floki.parse_document!()
    |> Floki.find("a[href]")
    |> Stream.map(&Floki.attribute(&1, "href"))
    |> Stream.map(&hd/1)
    |> Stream.map(&URI.merge(uri, &1))
    |> Enum.reject(&(&1.host != uri.host))
    |> dbg(label: :found)
  end
end
