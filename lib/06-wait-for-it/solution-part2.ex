# Problem text: https://adventofcode.com/2023/day/6

defmodule AOC2023.WaitForItPart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    lines
    |> parse_lines()
    |> get_first_and_last_solution()
    |> get_nr_solution_for_race()
  end

  @doc """
  Parses the given time and distance lines into a list of tuples.

  Example:

      iex> AOC2023.WaitForItPart2.parse_lines(["Time: 1 2 3", "Distance: 4 5 6"])
      {123, 456}
  """
  def parse_lines(lines) do
    lines
    |> Enum.map(fn line ->
      [_label | values] = String.split(line, " ", trim: true)

      parsed_values =
        values
        |> Enum.join()
        |> String.to_integer()

      parsed_values
    end)
    |> List.to_tuple()
  end

  @doc """
  Computes the first time at which the distance is greater than the record distance.

  Example:

      iex> AOC2023.WaitForItPart2.get_first_and_last_solution({7, 9})
      {2, 5}
  """
  def get_first_and_last_solution({time, record_distance}) do
    first_solution =
      0..time
      |> Enum.reduce_while(nil, fn t, _ ->
        speed = time - t
        distance = speed * t

        if distance > record_distance do
          {:halt, t}
        else
          {:cont, nil}
        end
      end)

    last_solution =
      0..time
      |> Enum.reverse()
      |> Enum.reduce_while(nil, fn t, _ ->
        speed = time - t
        distance = speed * t

        if distance > record_distance do
          {:halt, t}
        else
          {:cont, nil}
        end
      end)

    {first_solution, last_solution}
  end

  def get_nr_solution_for_race({first_solution, last_solution}) do
    last_solution - first_solution + 1
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
