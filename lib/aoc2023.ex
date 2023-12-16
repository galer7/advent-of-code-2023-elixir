defmodule AOC2023 do
  use Application

  def start(_type, _args) do
    IO.puts("[AOC2023] Starting...")

    IO.puts("[Day 1] Trebuchet, part 1 #{AOC2023.Trebuchet.solve()}")
    IO.puts("[Day 1] Trebuchet, part 2 #{AOC2023.TrebuchetPart2.solve()}")
    IO.puts("[Day 2] Cube Conundrum, part 1 #{AOC2023.CubeConundrum.solve()}")
    IO.puts("[Day 2] Cube Conundrum, part 2 #{AOC2023.CubeConundrumPart2.solve()}")
    IO.puts("[Day 3] Part Numbers, part 1 #{AOC2023.GearRatios.solve()}")
    IO.puts("[Day 3] Part Numbers, part 2 #{AOC2023.GearRatiosPart2.solve()}")
    IO.puts("[Day 4] Scratch Cards, part 1 #{AOC2023.ScratchCards.solve()}")
    IO.puts("[Day 4] Scratch Cards, part 2 #{AOC2023.ScratchCardsPart2.solve()}")
    IO.puts("[Day 5] Fertilizer, part 1 #{AOC2023.Fertilizer.solve()}")
    IO.puts("[Day 5] Fertilizer, part 2 #{AOC2023.FertilizerPart2.solve()}")
    IO.puts("[Day 6] Wait For It, part 1 #{AOC2023.WaitForIt.solve()}")
    # IO.puts("[Day 6] Wait For It, part 2 #{AOC2023.WaitForItPart2.solve()}")
    IO.puts("[Day 7] Camel Poker, part 1 #{AOC2023.CamelPoker.solve()}")
    IO.puts("[Day 7] Camel Poker, part 2 #{AOC2023.CamelPokerPart2.solve()}")
    IO.puts("[Day 8] Haunted Wasteland, part 1 #{AOC2023.HauntedWasteland.solve()}")
    IO.puts("[Day 8] Haunted Wasteland, part 2 #{AOC2023.HauntedWastelandPart2.solve()}")
    IO.puts("[Day 9] Mirage Maintenance, part 1 #{AOC2023.MirageMaintenance.solve()}")
    IO.puts("[Day 9] Mirage Maintenance, part 2 #{AOC2023.MirageMaintenancePart2.solve()}")

    IO.puts("[AOC2023] Done")

    # Return empty child spec in order to satisfy start callback
    # See https://stackoverflow.com/questions/30687781/how-to-run-an-elixir-application#comment49441617_30688873
    # https://hexdocs.pm/elixir/Application.html#c:start/2
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
