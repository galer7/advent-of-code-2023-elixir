defmodule AOC2023.CamelPokerPart2Test do
  use ExUnit.Case
  doctest AOC2023.CamelPokerPart2

  test "should run example" do
    input = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"

    assert AOC2023.CamelPokerPart2.do_solve(String.split(input, "\n")) == 5905
  end
end
