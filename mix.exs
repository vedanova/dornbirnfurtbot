defmodule Dornbirnfurtbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :dornbirnfurtbot,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Dornbirnfurtbot, []},
      extra_applications: [:logger, :plug, :cowboy, :facebook_messenger, :alexa]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:facebook_messenger,
       git: "https://github.com/corck/facebook_messenger.git", branch: "broadcast-functionality"},
      {:plug, "~> 1.4.4"},
      {:cowboy, "~> 1.1.2"},
      {:mox, "~> 0.3.1"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:alexa, "~> 0.1.6"}
    ]
  end
end
