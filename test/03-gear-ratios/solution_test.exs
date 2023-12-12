defmodule AOC2023.GearRatiosTest do
  use ExUnit.Case
  doctest AOC2023.GearRatios

  test "should run example" do
    input = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

    assert AOC2023.GearRatios.do_solve(String.split(input, "\n")) == 4361
  end
end
