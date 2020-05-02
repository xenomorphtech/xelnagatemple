### Why
First you realize Terraform is only for cloud.  
Then you start fighting to get Ansible to play nice.  
Finally you realize there are no other tools.  

### Running
Your modules/ are building blocks ontop of common.  Apt, Pacman, Files, etc.

Core Modules Included:
- Apt
- File
- Hostname

Your plays/ are sequences to get your desired state.

Your xel/ are your node configurations.

### Example
```elixir
xel = %{
  hosts: [
    %{hostname: "m1", ip: "1.1.1.1"},
    %{hostname: "m2", ip: "1.1.1.2"},
    %{hostname: "s1", ip: "1.1.1.3"},
    %{hostname: "s2", ip: "1.1.1.4"},
    %{hostname: "s3", ip: "1.1.1.5"},
  ]
}

defmodule Boot do
  @apt_remove [
    "snap",
    "unattended-upgrades"
  ]

  @apt_install [
    "vim",
    "git"
  ]

  def hosts(host, hosts) do
    bin = Enum.reduce(hosts, "", fn(host, acc)->
      acc <> "#{host.ip} #{host.hostname}\n"
    end)
    """
    127.0.0.1 localhost
    127.0.0.1 #{host.hostname}

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts

    #{bin}
    """
  end

  def play(state) do
    XNT.Hostname.set(state)

    XNT.File.copy(state, "/etc/hosts", hosts(state.host, state.hosts))

    XNT.Apt.remove(state, @apt_remove)
  end
end

XNT.Play.play xel, [Boot]
```

This play sets the hostname of every node, sets its hostsfile to the entire group and installs vim and git.