defmodule AOC2023.HauntedWastelandPart2Test do
  use ExUnit.Case
  doctest AOC2023.HauntedWastelandPart2

  test "should run example" do
    input = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"

    assert AOC2023.HauntedWastelandPart2.do_solve(String.split(input, "\n")) == 6
  end
end
