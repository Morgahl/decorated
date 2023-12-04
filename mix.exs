defmodule Decorated.MixProject do
  use Mix.Project

  def project do
    [
      app: :decorated,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),

      # Docs
      name: "Decorated",
      source_url: "https://github.com/Morgahl/decorated",
      homepage_url: "https://morgahl.github.io/decorated/",
      docs: [
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:examples), do: ["lib", "examples"]
  defp elixirc_paths(:test), do: ["lib", "examples", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false, optional: true},
      # {:decorator, "~> 1.4"},
      {:decorator, path: "decorator"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false, optional: true},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false, optional: true}
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :app_tree
    ]
  end
end
