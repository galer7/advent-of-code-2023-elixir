defmodule AOC2023.PipeMazeTest do
  use ExUnit.Case
  # doctest AOC2023.PipeMaze

  test "should run first example" do
    input = ".....
.S-7.
.|.|.
.L-J.
....."

    assert AOC2023.PipeMaze.do_solve(String.split(input, "\n")) == 4
  end

  test "should run second example" do
    input = "-L|F7
7S-7|
L|7||
-L-J|
L|-JF"

    assert AOC2023.PipeMaze.do_solve(String.split(input, "\n")) == 4
  end

  test "should run third example" do
    input = "..F7.
.FJ|.
SJ.L7
|F--J
LJ..."

    assert AOC2023.PipeMaze.do_solve(String.split(input, "\n")) == 8
  end

  test "should run fourth example" do
    input = "7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"

    assert AOC2023.PipeMaze.do_solve(String.split(input, "\n")) == 8
  end
end
