defmodule ExSpring83.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :exspring83,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExSpring83.Application, []}
    ]
  end

  defp deps do
    [
      {:cachex, "~> 3.4"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ed25519, "~> 1.4"},
      {:excoveralls, "~> 0.14.5", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  defp aliases do
    ["spring83.server": "run --no-halt"]
  end
end
