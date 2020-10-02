defmodule XNT.Module.SSH do
    def execute(state, command) do
        XNT.SSHWrap.execute(state, command)
    end
end
