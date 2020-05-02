defmodule XNT.File do
    def copy(state, path, bin) do
        content = XNT.SSHSFTPWrap.read_file(state, path)
        if content == bin do
            nil
        else
            :ok = XNT.SSHSFTPWrap.write_file(state, path, bin)
        end
    end
end