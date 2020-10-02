defmodule XNT.Module.Module do
  @moduledoc """
  Helper module to give easy scoping to all build-in modules.
  """

  defmacro __using__(_) do
    quote do
      alias XNT.Module.Apt, warn: false
      alias XNT.Module.Git, warn: false
      alias XNT.Module.Hostname, warn: false
      alias XNT.Module.SFTP, warn: false
      alias XNT.Module.SSH, warn: false
      alias XNT.Module.Systemctl, warn: false
    end
  end
end
