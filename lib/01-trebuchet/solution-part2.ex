# Problem text: https://adventofcode.com/2023/day/1

defmodule AOC2023.TrebuchetPart2 do
  @moduledoc """
  This is the solution to part 2 of the problem.
  """

  @doc """
  Calls the solver for part 2 of the problem.

  Returns the result of part 2 of the problem.
  """
  def solve do
    lines = read_file(relative_from_here("input.txt"))

    do_solve(lines)
  end

  @doc """
  Solves the problem with the given lines.

  Returns the result for given lines.

  Examples:

      iex> AOC2023.TrebuchetPart2.do_solve(["one123two456three789", "123", "one", "two", "three"])
      # 19 + 13 + 11 + 22 + 33 = 98
      98

      iex> AOC2023.TrebuchetPart2.do_solve(["1", "2", "3"])
      # 11 + 22 + 33 = 66
      66

      iex> AOC2023.TrebuchetPart2.do_solve(["one", "two", "three"])
      # 11 + 22 + 33 = 66
      66

      iex> AOC2023.TrebuchetPart2.do_solve([])
      0
  """
  def do_solve(lines) do
    lines
    |> Enum.map(&line_to_num_str/1)
    |> Enum.map(&num_str_to_int/1)
    |> Enum.sum()
  end

  @doc """
  Parse a line of the calibration document.

  Returns the first and last digit (as a string) of the calibration value.

  Examples:

      iex> AOC2023.TrebuchetPart2.line_to_num_str("one123two456three789")
      "19"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("123")
      "13"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("one")
      "11"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("2")
      "22"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("ch6")
      "66"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("5twelve1")
      "51"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("eighthree")
      "83"

      iex> AOC2023.TrebuchetPart2.line_to_num_str("sevenine")
      "79"
  """
  def line_to_num_str(line) do
    # We need to check if a real digit occurs before a spelled out digit.
    # If so, we need to ignore the spelled out digit.

    digits_re = ~r/(?=(0|1|2|3|4|5|6|7|8|9|one|two|three|four|five|six|seven|eight|nine))/
    results = Regex.scan(digits_re, line)

    [_, first] = Enum.at(results, 0)
    [_, last] = Enum.at(results, -1)

    [first, last]
    |> Enum.map(fn digit ->
      case digit do
        "one" -> "1"
        "two" -> "2"
        "three" -> "3"
        "four" -> "4"
        "five" -> "5"
        "six" -> "6"
        "seven" -> "7"
        "eight" -> "8"
        "nine" -> "9"
        _ -> digit
      end
    end)
    |> Enum.join()
  end

  @doc """
  Convert a num string to an integer.

  Returns the integer. If the string is not a number, returns 0.

  Examples:

      iex> AOC2023.TrebuchetPart2.num_str_to_int("123")
      123

      iex> AOC2023.TrebuchetPart2.num_str_to_int("")
      0

      iex> AOC2023.TrebuchetPart2.num_str_to_int("abc")
      0
  """
  def num_str_to_int(num_str) do
    case Integer.parse(num_str) do
      {num, _} ->
        num

      _ ->
        0
    end
  end

  defp read_file(path) do
    IO.puts("[read_file] Reading from #{path}")

    case File.read(path) do
      {:ok, content} ->
        IO.puts("[read_file] Read #{content |> String.length()} bytes")
        content |> String.split("\n")

      {:error, reason} ->
        raise "Error reading file: #{reason}"
    end
  end

  defp relative_from_here(path) do
    new_path = Path.join(__DIR__, path)
    new_path
  end
end
