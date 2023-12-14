# Problem text: https://adventofcode.com/2023/day/5

defmodule AOC2023.Fertilizer do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    seeds = get_seeds(lines)
    mappers = get_mappers(lines)

    Enum.min(
      Enum.map(seeds, fn seed ->
        traverse_mappers_with_value(seed, mappers)
      end)
    )
  end

  def get_seeds(lines) do
    [seed_line | _] = lines

    seed_line
    |> String.split(": ")
    |> List.last()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Traverses a list of mappers, starting with a value, and returns the final value.

  Examples:

      iex> AOC2023.Fertilizer.traverse_mappers_with_value(1, [[%{start: 2, end: 4, map_to: 1}, %{start: 5, end: 10, map_to: 4}]])
      1

      iex> AOC2023.Fertilizer.traverse_mappers_with_value(2, [[%{start: 2, end: 4, map_to: 1}, %{start: 5, end: 10, map_to: 4}]])
      1

      iex> AOC2023.Fertilizer.traverse_mappers_with_value(3, [[%{start: 2, end: 4, map_to: 1}, %{start: 5, end: 10, map_to: 4}]])
      # 3 maps to 2
      2

      iex> AOC2023.Fertilizer.traverse_mappers_with_value(10, [[%{start: 10, end: 20, map_to: 1}], [%{start: 1, end: 5, map_to: 2}]])
      # 10 maps to 1, then 1 maps to 2
      2
  """
  def traverse_mappers_with_value(value, mappers) do
    [current_mapper | rest_mappers] = mappers

    mapped_value =
      Enum.reduce_while(current_mapper, value, fn interval, acc ->
        if value in interval[:start]..interval[:end] do
          diff = value - interval[:start]
          {:halt, interval[:map_to] + diff}
        else
          {:cont, acc}
        end
      end)

    if length(rest_mappers) == 0 do
      mapped_value
    else
      traverse_mappers_with_value(mapped_value, rest_mappers)
    end
  end

  @doc """
  Returns a list of maps, each map representing a mapping from a source to a destination.

  Examples:

  iex> AOC2023.Fertilizer.get_mappers(["", "", "map:", "1 2 3", "4 5 6", "", "map:", "7 8 9", "10 11 12"])
  [[%{start: 2, end: 4, map_to: 1}, %{start: 5, end: 10, map_to: 4}],
   [%{start: 8, end: 16, map_to: 7}, %{start: 11, end: 22, map_to: 10}]]

  iex> AOC2023.Fertilizer.get_mappers(["", "", "map:", "1 2 3", "4 5 6", "", "map:", "7 8 9", "10 11 12", "", "map:", "13 14 15", "16 17 18"])
  [[%{start: 2, end: 4, map_to: 1}, %{start: 5, end: 10, map_to: 4}], [%{start: 8, end: 16, map_to: 7}, %{start: 11, end: 22, map_to: 10}], [%{start: 14, end: 28, map_to: 13}, %{start: 17, end: 34, map_to: 16}]]
  """
  def get_mappers(lines) do
    lines
    |> Enum.drop(2)
    |> Enum.reduce([], fn line, acc ->
      cond do
        String.contains?(line, "map:") ->
          acc ++ [[]]

        line == "" ->
          acc

        true ->
          [dest, src, count] =
            line
            |> String.split(" ")
            |> Enum.map(&String.to_integer/1)

          if length(acc) == 0 do
            [[%{start: src, end: src + count - 1, map_to: dest}]]
          else
            List.replace_at(
              acc,
              -1,
              List.last(acc) ++ [%{start: src, end: src + count - 1, map_to: dest}]
            )
          end
      end
    end)
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
