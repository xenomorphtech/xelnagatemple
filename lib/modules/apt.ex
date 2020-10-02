defmodule XNT.Module.Apt do
  def dist_upgrade(state) do
    cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade"
    {text, 0} = XNT.SSHWrap.execute(state, cmd)
    text
  end

  def remove(state, pkgs) do
    cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y remove " <> Enum.join(pkgs, " ")
    {text, 0} = XNT.SSHWrap.execute(state, cmd)
    text
  end

  def install(state, pkgs) do
    cmd = "DEBIAN_FRONTEND=noninteractive apt-get update"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    cmd = "DEBIAN_FRONTEND=noninteractive apt-get -y install " <> Enum.join(pkgs, " ")
    {text, 0} = XNT.SSHWrap.execute(state, cmd)
    text
  end
end
