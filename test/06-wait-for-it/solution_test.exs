defmodule AOC2023.WaitForItTest do
  use ExUnit.Case
  doctest AOC2023.WaitForIt

  test "should run example" do
    input = "Time:      7  15   30
Distance:  9  40  200"

    assert AOC2023.WaitForIt.do_solve(String.split(input, "\n")) == 288
  end
end
