defmodule AOC2023.GearRatiosPart2Test do
  use ExUnit.Case
  doctest AOC2023.GearRatiosPart2

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

    assert AOC2023.GearRatiosPart2.do_solve(String.split(input, "\n")) == 467_835
  end
end
