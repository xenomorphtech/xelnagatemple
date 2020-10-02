defmodule XNT.SSHCtx do
    def init(ip, port \\ 22, user \\ "root", pass \\ nil) do
        ssh_sock = XNT.SSHWrap.connect(ip, port, user, pass)
        sftp_sock = XNT.SSHSFTPWrap.connect(ip, port, user, pass)
        %{ssh: ssh_sock, sftp: sftp_sock}
    end
end
