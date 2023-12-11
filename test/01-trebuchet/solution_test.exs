defmodule AOC2023.TrebuchetTest do
  use ExUnit.Case
  doctest AOC2023.Trebuchet

  test "should run example" do
    input = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"

    assert AOC2023.Trebuchet.do_solve(String.split(input, "\n")) == 142
  end
end
