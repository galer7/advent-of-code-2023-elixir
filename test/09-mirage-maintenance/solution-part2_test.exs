defmodule AOC2023.MirageMaintenancePart2Test do
  use ExUnit.Case
  doctest AOC2023.MirageMaintenancePart2

  test "should run example" do
    input = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"

    assert AOC2023.MirageMaintenancePart2.do_solve(String.split(input, "\n")) == 2
  end
end
