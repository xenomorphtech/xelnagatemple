defmodule XNT.SSHWrap do
    def connect(host, port \\ 22, user \\ "root", pass \\ nil) do
        args = [{:user, '#{user}'}, {:silently_accept_hosts, true}, {:user_interaction, false}, {:connect_timeout, 15_000}]
        args = if pass, do: [{:password, pass} | args], else: args
        {:ok, ref} = :ssh.connect('#{host}', port, args, 15_000)
        %{ref: ref}
    end

    def execute(state, cmd) do
        ssh_ctx = state.ssh_ctx
        {:ok, channelId} = :ssh_connection.session_channel(ssh_ctx.ssh.ref, :infinity)
        :success = :ssh_connection.exec(ssh_ctx.ssh.ref, channelId, cmd, :infinity)
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
