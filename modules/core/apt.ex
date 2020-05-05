defmodule XNT.Apt do
    def dist_upgrade(state) do
        cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade"
        {r, 0} = XNT.SSHWrap.execute(state, cmd)
        r
    end

    def remove(state, pkgs) do
        cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y remove " <> Enum.join(pkgs, " ")
        {r, 0} = XNT.SSHWrap.execute(state, cmd)
        r
    end

    def install(state, pkgs) do
        cmd = "DEBIAN_FRONTEND=noninteractive apt-get update"
        {r, 0} = XNT.SSHWrap.execute(state, cmd)
        cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y install " <> Enum.join(pkgs, " ")
        {r, 0} = XNT.SSHWrap.execute(state, cmd)
        r
    end
end