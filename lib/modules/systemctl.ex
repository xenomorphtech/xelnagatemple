defmodule XNT.Module.Systemctl do
  def reload_services(state) do
    cmd = "systemctl daemon-reload"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    :ok
  end

  def disable_service(state, name) do
    cmd = "systemctl disable #{name}"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    :ok
  end

  def enable_service(state, name) do
    cmd = "systemctl enable #{name}"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    :ok
  end

  def stop_service(state, name) do
    cmd = "systemctl stop #{name}"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    :ok
  end

  def start_service(state, name) do
    cmd = "systemctl start #{name}"
    {_, 0} = XNT.SSHWrap.execute(state, cmd)
    :ok
  end
end
