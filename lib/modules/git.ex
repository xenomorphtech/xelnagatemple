defmodule XNT.Module.Git do
  def add_key(state, host) do
    {result, 0} = XNT.SSHWrap.execute(state, "ssh-keyscan -trsa #{host}")
    XNT.Module.SFTP.line_in_file(state, "~/.ssh/known_hosts", result)
  end

  def clone(state, repo, path) do
    case XNT.SSHWrap.execute(state, "git clone #{repo} #{path}") do
      {result, 0} -> result
      {_, 128} -> :exists
    end
  end

  def pull(state, path) do
    {result, 0} = XNT.SSHWrap.execute(state, "cd #{path} && git pull")
    result
  end
end
