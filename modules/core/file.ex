defmodule XNT.File do
    def copy(state, bin, path) do
        content = XNT.SSHSFTPWrap.read_file(state, path)
        if content == bin do
            Color.print {path, "same"}
            nil
        else
            :ok = XNT.SSHSFTPWrap.write_file(state, path, bin)
        end
    end

    def line_in_file(state, bin, path) do
        content = XNT.SSHSFTPWrap.read_file(state, path)
        if content =~ bin do
            nil
        else
            bin = content <> "\n" <> bin
            :ok = XNT.SSHSFTPWrap.write_file(state, path, bin)
        end
    end
end