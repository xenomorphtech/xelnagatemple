defmodule XNT.Module.Systemctl do
    def disable_service(state, name) do
        cmd = "systemctl disable #{name}"
        {_, 0} = XNT.SSHWrap.execute(state, cmd)
        :ok
    end

    def enable_service(state, name) do
        cmd = "systemctl enable #{name}"
        {_, 0} = XNT.SSHWrap.execute(state, cmd)
        :ok
    end

    def reload_services(state) do
        cmd = "systemctl daemon-reload"
        {_, 0} = XNT.SSHWrap.execute(state, cmd)
        :ok
    end
end
