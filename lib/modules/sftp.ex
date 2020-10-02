defmodule XNT.Module.SFTP do
    require Record
    Record.defrecord(:file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl"))

    def write(state, path, bin) do
        XNT.SSHSFTPWrap.write_file(state, path, bin)
    end

    def read(state, path) do
        XNT.SSHSFTPWrap.read_file(state, path)
    end

    def permissions(state, path, mode) do
        fi = file_info(mode: mode)
        XNT.SSHSFTPWrap.write_file_info(state, path, fi)
    end

    def write_if_changed(state, path, bin) do
        content = XNT.SSHSFTPWrap.read_file(state, path)
        if content == bin do
            Color.print {path, "same"}
            nil
        else
            :ok = XNT.SSHSFTPWrap.write_file(state, path, bin)
        end
    end

    def line_in_file(state, path, line) do
        content = XNT.SSHSFTPWrap.read_file(state, path)
        cond do
            content =~ line -> nil
            content == nil ->
                :ok = XNT.SSHSFTPWrap.write_file(state, path, line)
            String.last(content) != "\n" ->
                line = content <> "\n" <> line
                :ok = XNT.SSHSFTPWrap.write_file(state, path, line)
            true ->
                line = content <> line
                :ok = XNT.SSHSFTPWrap.write_file(state, path, line)
        end
    end
end
