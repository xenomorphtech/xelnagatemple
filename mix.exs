defmodule XNT.MixProject do
  use Mix.Project

  @app :xelnagatemple

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_env: [release: :prod]
    ]
  end

  def application do
    apps = [
      extra_applications: [:logger, :ssl, :ssh]
    ]

    if Mix.env() == :prod do
      [{:mod, {XNT.Bakeware, []}} | apps]
    else
      [{:mod, {XNT, []}} | apps]
    end
  end

  defp deps do
    [
      {:bakeware,
       git: "https://github.com/bake-bake-bake/bakeware", branch: "main", runtime: false}
    ]
  end

  defp release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      steps: [:assemble, &Bakeware.assemble/1],
      strip_beams: Mix.env() == :prod
    ]
  end
end
