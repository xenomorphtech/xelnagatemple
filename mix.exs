defmodule XNT.MixProject do
  use Mix.Project

  @app :xelnagatemple

  def project do
    [
      app: @app,
      version: "0.1.1",
      elixir: ">= 1.18.0",
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
      steps: [:assemble, &Bakeware.assemble/1],
      strip_beams: Mix.env() == :prod,
      bakeware: [
        compression_level: 1,
        #compression_level: 19,
        start_command: "start_iex"
      ],
    ]
  end
end
