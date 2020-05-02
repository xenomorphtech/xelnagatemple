defmodule XNT.SSock do
    def get_ssock(s) do
        ssock = Process.get(:ssock)
        if ssock do ssock else
            ssh_sock = XNT.SSHWrap.connect(s.host.ip)
            sftp_sock = XNT.SSHSFTPWrap.connect(s.host.ip)
            ssock = %{ssh: ssh_sock, sftp: sftp_sock}
            Process.put(:ssock, ssock)
            ssock
        end
    end
end