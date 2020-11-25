### About
A xel'naga temple is a xel'naga structure, found on various worlds. Some temples have special functions.

### Example
```

./xelnagatemple xel_file play_file.ex

Running with xel/xel_file play_file.ex
Loaded your Xel
%{hosts: [%{hostname: "s1", ip: "1.2.3.4"}]}

Compiling plays..


Loaded play modules [Init]

s1 - {:hostname, :set, "s1"}
s1 - {:apt, :start}
s1 - {:apt, :done}
s1 - {:system_config, :done}
s1 - {:performance_governer, :set, :performance}
s1 - {:updating_grub, :reboot_required}
s1 - {:install_erlang_and_elixir, :start}
s1 - {:install_erlang_and_elixir, :done}
s1 - {:install_rust, :start}
s1 - {:install_rust, :done}
s1 - {:rebooting}
s1 - {:done}
```


### Philosopy
Scriptable.

Lean and single file.

No nested complex file and folder structures like ansible.

Direct access to SSH and SFTP.

Mostly came out of a need from how hard it is to do complex network adapter configurations using ansible.

### Xel
Xel are your nodes.  Insert custom parameters you want to pass to your plays here.


```
%{
  hosts: [
    %{hostname: "loadbalancer1", ip: "95.12.31.10", ssh_port: 5555, ssh_user: "balancer"},
    %{hostname: "loadbalancer2", ip: "95.12.31.11", ssh_port: 5555, ssh_user: "balancer"},
    %{hostname: "worker1", ip: "95.12.31.100"},
    %{hostname: "worker2", ip: "95.12.31.101"},
    %{hostname: "worker3", ip: "95.12.31.102"},
    %{hostname: "worker4", ip: "95.12.31.103", custom_field: "hi"},
  ]
}

```

Map fields for xel host
```
ip - Manditory
hostname - Optional
ssh_port - Optional, default 22
ssh_user - Optional, default root
ssh_password - Optional, default use publickey auth
```


### Plays
Plays are your state transitions.  The entire xel map is passed as state with a few preprogrammed keys.

```
state.host =  xel_map //ex: %{hostname: "loadbalancer1", ip: "95.12.31.10"}
state.hosts = xel_hosts_list
```

Each play executes once for every host, with all hosts in parallel.

Each playfile must contain elixir modules.

Each playfile must contain one elixir module called Init, which will have play/1 called first.

Some tips on writing plays, generally try to stick to shellscript if possible since that is portable code.

Use the builtin Modules only when necessary.


### Built-in Modules
SSH
```
@spec execute(map(), String.t()) :: nil | :ok
execute(state, command)
```

SFTP
```
@spec write(map(), String.t(), String.t()) :: :ok
write(state, path, content)

@spec read(map(), String.t()) :: nil | :ok
read(state, path)

@moduledoc """Read file at path, if it equals content return nil otherwise append line and return :ok"""
@spec write_if_changed(map(), String.t(), String.t()) :: nil | :ok
write_if_changed(state, path, content)

@moduledoc """Read file at path, if it contains line return nil otherwise append line and return :ok"""
@spec line_in_file(map(), String.t(), String.t()) :: nil | :ok
line_in_file(state, path, content)
```

Apt
```
@spec dist_upgrade(map()) :: String.t()
dist_upgrade(state)

@spec remove(map(), [String.t()]) :: String.t()
remove(state, packages)

@spec install(map(), [String.t()]) :: String.t()
install(state, packages)
```

Git
```
@moduledoc """Add pubkey for ssh-keyscan -trsa hostname, if ~/.ssh/known_hosts does not contain it"""
@spec add_key(map(), String.t()) :: nil | :ok
add_key(state, hostname)

@moduledoc """Clone a repo into path if it does not exist"""
@spec clone(map(), String.t(), String.t()) :: nil | :ok
clone(state, repo, path)
```

Hostname
```
@moduledoc """Execute hostnamectl set-hostname hostname"""
@spec set(map(), String.t()) :: :ok
set(state, hostname)
```

Systemctl
```
@spec disable_service(map(), String.t()) :: :ok
@spec enable_service(map(), String.t()) :: :ok
@spec reload_services(map()) :: :ok
```


### Example2
```
./xelnagatemple xel_file play_file.ex
```

Simple but detailed example

```elixir
defmodule Init do
  use XNT.Module.Module

  def play(state) do
    Hostname.set(state)
    Color.print({:hostname, :set, state.host.hostname})

    Color.print({:apt, :start})
    cmd = """
    apt-get install -y vim git apt-utils net-tools locate screen mosh tmux gnupg smartmontools \
    linux-tools-common linux-tools-generic lm-sensors hddtemp \
    iotop iftop ncdu mtr-tiny secure-delete sysstat \
    python-is-python3

    apt-get purge -y unattended-upgrades snap

    apt-get -y dist-upgrade
    """
    {_, 0} = SSH.execute(state, cmd)
    Color.print({:apt, :done})

    SFTP.write(state, "/etc/security/limits.conf", File.read!("plays/template/limits.conf"))
    SFTP.write(state, "/etc/sysctl.conf", File.read!("plays/template/sysctl.conf"))
    SFTP.write(state, "/etc/systemd/user.conf", File.read!("plays/template/system.conf"))
    SFTP.write(state, "/etc/systemd/system.conf", File.read!("plays/template/system.conf"))
    Color.print({:system_config, :done})

    service_cpu(state, :ht)
    Color.print({:performance_governer, :set, :performance})

    setup_grub(state, %{hugepages: 0, mitigations: :off})

    Color.print({:install_erlang_and_elixir, :start})
    install_erlang_and_elixir(state)
    Color.print({:install_erlang_and_elixir, :done})

    if SFTP.read(state, "/tmp/reboot_required") do
      Color.print({:rebooting})
      SSH.execute(state, "reboot &")
    end
    Color.print({:done})
  end

  def setup_grub(state, opts) do
    file = File.read!("plays/template/grub")
    mitigations = Map.get(opts, :mitigations, :on)
    hugepages = Map.get(opts, :hugepages, 0)

    file = String.replace(file, "{{mitigations}}", "#{mitigations}")
    file = String.replace(file, "{{hugepages}}", "#{hugepages}")

    if SFTP.write_if_changed(state, "/etc/default/grub", file) == :ok do
      Color.print({:updating_grub, :reboot_required})
      SFTP.write(state, "/tmp/reboot_required", "")
      {_, 0} = SSH.execute(state, "update-grub")
    end
  end

  def service_cpu(state, ht \\ :ht) do
    Systemctl.disable_service(state, "ondemand")

    ht = if ht == :no_ht do
      #cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | awk -F, '{print $2}' | sort -n | uniq | ( while read X ; do echo $X ; echo 0 > /sys/devices/system/cpu/cpu$X/online ; done )\n"
      """
      cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | \
      awk -F, '{print $2}' | \
      sort -n | \
      uniq | \
      ( while read X ; do echo $X ; echo 0 > /sys/devices/system/cpu/cpu$X/online ; done )
      """
    else "" end

    sh = """
    #!/bin/bash
    set -x

    /usr/bin/cpupower frequency-set --governor performance
    /usr/bin/cpupower --cpu all idle-set --disable 2

    #{ht}
    """

    service = """
    [Unit]
    Description=XNT CPU
    After=multi-user.target

    [Service]
    Type=oneshot
    RemainAfterExit=no
    ExecStart=/bin/bash /opt/cpu_xnt.sh

    [Install]
    WantedBy=default.target
    """

    SFTP.write(state, "/etc/systemd/system/cpu_xnt.service", service)
    SFTP.write(state, "/opt/cpu_xnt.sh", sh)
    {_, 0} = SSH.execute(state, "chmod +x /opt/cpu_xnt.sh")
    Systemctl.enable_service(state, "cpu_xnt")
  end

  def install_erlang_and_elixir(state) do
    cmd = """
    apt-get install -y build-essential autoconf libncurses-dev m4 libssl-dev xsltproc libxml2-utils unixodbc-dev
    """
    {_, 0} = SSH.execute(state, cmd)

    cmd = """
    mkdir -p /root/source
    git clone https://github.com/erlang/otp /root/source/otp
    cd /root/source/otp
    git checkout OTP-23.1.1
    ./otp_build autoconf && ./configure --enable-lock-counter && make -j2 && make install
    """
    {_, 0} = SSH.execute(state, cmd)

    cmd = """
    mkdir -p /root/source
    git clone https://github.com/elixir-lang/elixir.git /root/source/elixir
    cd /root/source/elixir
    git checkout v1.10.4
    make clean && make install
    mix local.hex --force && mix local.rebar --force
    """
    {_, 0} = SSH.execute(state, cmd)
  end
end
```

Output of above example
```
Running with xel/egypt plays/boot.ex
Loaded your Xel
%{hosts: [%{hostname: "ra1", ip: "11.32.42.123"}]}

Compiling plays..


Loaded play modules [Init]

ra1 - {:hostname, :set, "ra1"}
ra1 - {:apt, :start}
ra1 - {:apt, :done}
ra1 - {:system_config, :done}
ra1 - {:performance_governer, :set, :performance}
ra1 - {:updating_grub}
ra1 - {:install_erlang_and_elixir, :start}
ra1 - {:install_erlang_and_elixir, :done}
ra1 - {:rebooting}
ra1 - {:done}
```

Example of multiple modules
```elixir
defmodule Init do
  @packages ["vim", "tcpdump", "iftop", "htop"]

  def play(state) do
    set_hostname(state)
    set_hostname_using_module(state)

    install_apt_packages(state)
    install_apt_packages_using_module(state, @packages)

    case state.host.hostname do
      "loadbalancer" <> _ -> Loadbalancer.do_stuff(state)
      "worker" <> _ -> Worker.do_stuff(state)
    end
  end

  def set_hostname(state) do
    hostname = state.host.hostname
    cmd = """
    echo #{hostname} > /etc/hostname
    """
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
  end

  def set_hostname_using_module(state) do
    XNT.Module.Hostname.set(state)
  end

  def install_apt_packages(state) do
    hostname = state.host.hostname
    cmd = """
    apt-get install -y vim tcpdump iftop htop
    """
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
  end

  def install_apt_packages_using_module(state, packages) do
     XNT.Module.Apt.install(state, packages)
  end
end

defmodule Loadbalancer do
  def do_stuff(state) do
  end
end

defmodule Worker do
  def do_other_stuff(state) do
  end
end
```

Example from REPL.

This play sets the hostname of every node, sets its hostsfile to the entire group and installs vim and git.

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
  #This is a helper alias shortcut
  use XNT.Module.Module

  @apt_remove [
    "snap",
    "unattended-upgrades"
  ]

  @apt_install [
    "vim",
    "git"
  ]

  def hosts_template(host, hosts) do
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
    Hostname.set(state)

    File.write(state, "/etc/hosts", hosts_template(state.host, state.hosts))

    Apt.remove(state, @apt_remove)
  end
end

XNT.Play.play(xel, [Boot])
```


### Building single binary
Run build.sh to plop the bin into `.`; for a 3x reduction in filesize make sure zstd is installed.
