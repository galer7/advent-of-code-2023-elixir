defmodule AOC2023.CamelPokerTest do
  use ExUnit.Case
  doctest AOC2023.CamelPoker

  test "should run example" do
    input = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"

    assert AOC2023.CamelPoker.do_solve(String.split(input, "\n")) == 6440
  end

  # https://www.reddit.com/r/adventofcode/comments/18cq5j3/2023_day_7_part_1_two_hints_for_anyone_stuck/
  test "should run Reddit example" do
    input = "AAAAA 2
22222 3
AAAAK 5
22223 7
AAAKK 11
22233 13
AAAKQ 17
22234 19
AAKKQ 23
22334 29
AAKQJ 31
22345 37
AKQJT 41
23456 43"

    assert AOC2023.CamelPoker.do_solve(String.split(input, "\n")) == 1343
  end
end
