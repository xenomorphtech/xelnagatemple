defmodule Color do
  def print(text) when not is_binary(text) do
    print(inspect(text, pretty: true))
  end

  def print(text) do
    {r, g, b} = get_color()
    pid = self() |> :erlang.pid_to_list() |> :erlang.list_to_binary()
    key = Process.get({XNT, :hostname}) || Process.get({XNT, :ip}) || pid
    IO.puts("\x1b[38;2;#{r};#{g};#{b}m#{key} - #{text}\x1b[0m")
  end

  def get_color() do
    color_3 = Process.get({XNT, :color_3})

    if !color_3 do
      hname = Process.get({XNT, :ip}) || :crypto.strong_rand_bytes(4)
      <<a, b, c, _>> = <<:erlang.crc32(hname)::32>>
      color_3 = {a, b, c}
      Process.put({XNT, :color_3}, color_3)
      color_3
    else
      color_3
    end
  end
end
