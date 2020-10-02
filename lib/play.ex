defmodule XNT.Play do
  def load(path, mods) do
    term = File.read!(path)
    {:ok, state} = ParseTerm.parse(term)
    play(state, mods)
  end

  def play(_, []), do: :done

  def play(state, [module | t]) do
    tasks =
      Enum.map(state.hosts, fn host ->
        state = Map.put(state, :host, host)

        Task.async(fn ->
          Process.put({XNT, :ip}, host[:ip])
          Process.put({XNT, :hostname}, host[:hostname])

          ssh_port = host[:ssh_port] || 22
          ssh_user = host[:ssh_user] || "root"
          ssh_password = host[:ssh_password]
          ssh_ctx = XNT.SSHCtx.init(host.ip, ssh_port, ssh_user, ssh_password)

          state = Map.put(state, :ssh_ctx, ssh_ctx)
          module.play(state)
        end)
      end)

    Task.yield_many(tasks, :infinity)
    play(state, t)
  end
end
