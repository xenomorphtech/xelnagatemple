defmodule XNT.Apt do
    def remove(state, pkgs) do
        cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y remove " <> Enum.join(pkgs, " ")
        {r, 0} = XNT.SSHWrap.execute(state, cmd)
        r
    end
    def remove(_), do: nil
end