defmodule XNT.MixProject do
  use Mix.Project

  def project do
    [
      app: :xelnagatemple,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: ["lib", "modules", "plays"]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ssl, :ssh],
      mod: {XNT, []}
    ]
  end

  defp deps do
    [
    ]
  end
end