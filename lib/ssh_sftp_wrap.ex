defmodule XNT.SSHSFTPWrap do
    def connect(host, port \\ 22, user \\ "root") do
        {:ok, channelPid, ref} = :ssh_sftp.start_channel('#{host}', port, 
            [{:user, '#{user}'}, {:silently_accept_hosts, true}, {:user_interaction, false}])
        %{ref: ref, channelPid: channelPid}
    end

    def read_file(state, path) do
        ssock = XNT.SSock.get_ssock(state)
        case :ssh_sftp.read_file(ssock.sftp.channelPid, '#{path}') do
            {:ok, data} -> data
            {:error, :no_such_file} -> ""
        end
    end

    def write_file(state, path, content) do
        ssock = XNT.SSock.get_ssock(state)
        :ok = :ssh_sftp.write_file(ssock.sftp.channelPid, '#{path}', '#{content}')
    end
end


