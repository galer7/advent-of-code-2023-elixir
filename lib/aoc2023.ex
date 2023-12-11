defmodule AOC2023 do
  use Application

  def start(_type, _args) do
    IO.puts("[AOC2023] Starting...")

    IO.puts("[Day 1] Trebuchet, part 1 #{AOC2023.Trebuchet.solve()}")
    IO.puts("[Day 1] Trebuchet, part 2 #{AOC2023.TrebuchetPart2.solve()}")
    IO.puts("[Day 2] Cube Conundrum, part 1 #{AOC2023.CubeConundrum.solve()}")
    IO.puts("[Day 3] Part Numbers, part 1 #{AOC2023.GearRatios.solve()}")

    IO.puts("[AOC2023] Done")

    # Return empty child spec in order to satisfy start callback
    # See https://stackoverflow.com/questions/30687781/how-to-run-an-elixir-application#comment49441617_30688873
    # https://hexdocs.pm/elixir/Application.html#c:start/2
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
