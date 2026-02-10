# WebCrawler

A simple webcrawler! Made as a little brain teaser.

## Specs

Starting from a given URL, find all URLs reachable from the start that belong to
the same hostname.

Simple requirements:
* Only crawl URLs with same hostname as startUrl
* Use the urls dictionary to get links from a page
* Avoid visiting the same url twice

Once the simple version is in place, some parallelization could be added. Or
some `robots.txt` handling. Add support for images, styles, scripts, etc.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `web_crawler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:web_crawler, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/web_crawler>.
