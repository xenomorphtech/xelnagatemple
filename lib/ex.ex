defmodule XNT do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    opts = [
      strategy: :one_for_one,
      name: XNT.Supervisor,
      max_seconds: 1,
      max_restarts: 999_999_999_999
    ]

    Supervisor.start_link(children, opts)
  end
end
