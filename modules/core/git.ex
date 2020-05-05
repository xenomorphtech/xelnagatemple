defmodule XNT.Git do
    def add_key(state, host) do
        {r, 0} = XNT.SSHWrap.execute(state, "ssh-keyscan -trsa #{host}")
        XNT.File.line_in_file(state, r, "~/.ssh/known_hosts")
    end

    def clone(state, repo, path) do
        case XNT.SSHWrap.execute(state, "git clone #{repo} #{path}") do
            {r, 0} -> r    
            {r, 128} -> :exists
        end
    end
end