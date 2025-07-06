defmodule XNT.Module.AuthorizedKeys do
  def set_for_root(state, sshkeys) do
    cmd = "cat /root/.ssh/authorized_keys"
    {keys, 0} = XNT.SSHWrap.execute(state, cmd)
    missing_keys = sshkeys -- String.split(keys, "\n")
    if missing_keys != [] do
        keyline = Enum.join(missing_keys, "\n")
        cmd = "printf '#{keyline}' | /root/.ssh/authorized_keys"
        {result, 0} = XNT.SSHWrap.execute(state, cmd)
        missing_keys
    end
  end

  def set_from_nonroot_for_root(state, sshkeys, sudo_password) do
    cmd = "echo '#{sudo_password}' | sudo -S -p '' cat /root/.ssh/authorized_keys"
    {keys, 0} = XNT.SSHWrap.execute(state, cmd)
    missing_keys = sshkeys -- String.split(keys, "\n")
    if missing_keys != [] do
        keyline = Enum.join(missing_keys, "\n")
        cmd = "echo '#{sudo_password}' | sudo -S -p '' sh -c \"printf '#{keyline}' | tee -a /root/.ssh/authorized_keys >/dev/null\""
        {result, 0} = XNT.SSHWrap.execute(state, cmd)
        missing_keys
    end
  end
end
