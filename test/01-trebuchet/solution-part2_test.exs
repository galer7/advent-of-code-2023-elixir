defmodule AOC2023.TrebuchetPart2Test do
  use ExUnit.Case
  doctest AOC2023.TrebuchetPart2

  test "should run example" do
    input = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"

    assert AOC2023.TrebuchetPart2.do_solve(String.split(input, "\n")) == 281
  end
end
