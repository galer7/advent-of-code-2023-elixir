defmodule AOC2023.WaitForItPart2Test do
  use ExUnit.Case
  doctest AOC2023.WaitForItPart2

  test "should run example" do
    input = "Time:      7  15   30
Distance:  9  40  200"

    assert AOC2023.WaitForItPart2.do_solve(String.split(input, "\n")) == 71503
  end
end
