defmodule XNT.SSHSFTPWrap do
  def connect(host, port \\ 22, user \\ "root", pass \\ nil) do
    args = [
      {:user, '#{user}'},
      {:silently_accept_hosts, true},
      {:user_interaction, false},
      {:connect_timeout, 15_000}
    ]

    args = if pass, do: [{:password, '#{pass}'} | args], else: args
    {:ok, channelPid, ref} = :ssh_sftp.start_channel('#{host}', port, args)
    %{ref: ref, channelPid: channelPid}
  end

  def exists(state, path) do
    ssh_ctx = state.ssh_ctx
    case :ssh_sftp.read_file_info(ssh_ctx.sftp.channelPid, '#{path}') do
      {:ok, _} -> true
      _ -> false
    end
  end

  def read_file(state, path) do
    ssh_ctx = state.ssh_ctx

    case :ssh_sftp.read_file(ssh_ctx.sftp.channelPid, '#{path}') do
      {:ok, data} -> data
      {:error, :no_such_file} -> nil
    end
  end

  def write_file(state, path, content) do
    ssh_ctx = state.ssh_ctx
    content = if is_binary(content) do :erlang.binary_to_list(content) else '#{content}' end
    :ok = :ssh_sftp.write_file(ssh_ctx.sftp.channelPid, '#{path}', content)
  end

  def write_file_info(state, path, modes) do
    ssh_ctx = state.ssh_ctx
    :ok = :ssh_sftp.write_file_info(ssh_ctx.sftp.channelPid, '#{path}', modes)
  end
end
