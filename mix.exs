defmodule ElixirChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_chat,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirChat.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:websock_adapter, "~> 0.5.7"},
      {:cors_plug, "~> 3.0"}
    ]
  end
end
