defmodule XNT.SSHWrap do
    def connect(host, port \\ 22, user \\ "root") do
        {:ok, ref} = :ssh.connect('#{host}', port, 
            [{:user, '#{user}'}, {:silently_accept_hosts, true}, {:user_interaction, false}])
        %{ref: ref}
    end

    def execute(state, cmd) do
        ssock = XNT.SSock.get_ssock(state)
        {:ok, channelId} = :ssh_connection.session_channel(ssock.ssh.ref, :infinity)
        :success = :ssh_connection.exec(ssock.ssh.ref, channelId, cmd, :infinity)
        flush()
    end

    def flush(r\\"", e\\nil) do
        receive do
            {:ssh_cm, _, {:data, _, _, bin}} -> flush(bin,e)
            {:ssh_cm, _, {:exit_status, _, ecode}} -> flush(r,ecode)
            {:ssh_cm, _, {:eof, _}} -> flush(r,e)
            {:ssh_cm, _, {:closed, _}} -> {r,e}
        after 900_000 ->
            :timeout
        end
    end
end