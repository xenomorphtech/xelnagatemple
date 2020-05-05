defmodule XNT.Play do
    def load(path, mods) do
        term = File.read!(path)
        {:ok, state} = ParseTerm.parse(term)
        play(state, mods)
    end

    def play(_,[]), do: :done
    def play(state, [module|t]) do
        tasks = Enum.map(state.hosts, fn(host) ->
            state = Map.put(state, :host, host)
            Task.async(fn ->
                Process.put({XNT,:hostname}, host[:hostname])
                module.play(state)
            end)
        end)
        Task.await_many(tasks, :infinity)
        play(state, t)
    end
end
