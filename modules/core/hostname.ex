defmodule XNT.Hostname do
    def set(state) do
        host = state.host
        cmd = "hostnamectl set-hostname #{host.hostname}"
        {"", 0} = XNT.SSHWrap.execute(state, cmd)
        :ok
    end
end