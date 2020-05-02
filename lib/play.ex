defmodule XNT.Play do
    def play(_,[]), do: :done
    def play(state, [module|t]) do
        Enum.each(state.hosts, fn(host)->
            state = Map.put(state,:host,host)
            module.play(state)
        end)
        play(state, t)
    end
end