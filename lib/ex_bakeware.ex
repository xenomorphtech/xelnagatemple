if Mix.env() == :prod do
  defmodule XNT.Bakeware do
    use Bakeware.Script

    @impl Bakeware.Script
    def main([xel_path, plays_path]) do
      :erlang.process_flag(:trap_exit, true)

      IO.puts("Running with #{xel_path} #{plays_path}")

      xel = File.read!(xel_path)
      {:ok, xel} = ParseTerm.parse(xel)
      IO.puts("Loaded your Xel")
      IO.inspect(xel, pretty: true, limit: :infinity)
      IO.puts("")

      IO.puts("Compiling plays..")
      IO.puts("")

      res = Code.compile_file(plays_path)
      play_modules = Enum.map(res, &elem(&1, 0))
      IO.puts("")
      IO.puts("Loaded play modules #{inspect(play_modules)}")
      IO.puts("")

      XNT.Play.play(xel, [Init])
      :io.put_chars("")
      0
    end

    def main(_) do
      IO.puts("Invalid args, use ./xelnagatemple xel_path plays_path")
      0
    end
  end
end
