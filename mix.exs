defmodule WebCrawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :web_crawler,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.38.0"},
      {:req, "~> 0.5.0"}
    ]
  end
end
