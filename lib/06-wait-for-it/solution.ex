# Problem text: https://adventofcode.com/2023/day/6

defmodule AOC2023.WaitForIt do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  @spec do_solve(any()) :: any()
  def do_solve(lines) do
    lines
    |> parse_lines()
    |> Enum.map(fn parsed_line ->
      get_nr_solution_for_race(parsed_line)
    end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  @doc """
  Parses the given time and distance lines into a list of tuples.

  Example:

      iex> AOC2023.WaitForIt.parse_lines(["Time: 1 2 3", "Distance: 4 5 6"])
      [{1, 4}, {2, 5}, {3, 6}]
  """
  def parse_lines(lines) do
    lines
    |> Enum.map(fn line ->
      [_label | values] = String.split(line, " ", trim: true)

      parsed_values =
        values
        |> Enum.map(fn value ->
          value |> String.to_integer()
        end)

      parsed_values
    end)
    |> Enum.zip()
  end

  def get_nr_solution_for_race({time, record_distance}) do
    0..time
    |> Enum.map(fn t ->
      speed = time - t
      distance = speed * t

      if distance > record_distance do
        true
      else
        false
      end
    end)
    |> Enum.count(fn x -> x == true end)
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
