defmodule AOC2023.HauntedWastelandTest do
  use ExUnit.Case
  doctest AOC2023.HauntedWasteland

  test "should run example" do
    input = "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"

    assert AOC2023.HauntedWasteland.do_solve(String.split(input, "\n")) == 6
  end
end
