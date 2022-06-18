defmodule RustMqApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :rust_mq_api,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :httpoison],
      mod: {ServerApp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:uuid,"~> 1.1"},
      {:cors_plug, "~> 3.0"},
    ]
  end
end
