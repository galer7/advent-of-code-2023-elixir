# Problem text: https://adventofcode.com/2023/day/5

defmodule AOC2023.FertilizerPart2 do
  @moduledoc """
  Solution for the second part of the fifth problem of the Advent of Code 2023.

  Terminology:
  - seed: a number that is used as input to the first mapper
  - mapper: a list of range maps, each range map mapping a range of numbers to another range of numbers
  - range map: a map with the following keys:
    - from: a range of numbers
    - to: a range of numbers
  """
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    all_mappers = create_all_mappers(lines)
    seed_intervals = get_seed_intervals(lines)

    output_intervals = pipe_seed_intervals_into_mappers(seed_intervals, all_mappers)

    input_min_with_identity =
      Enum.map(seed_intervals, fn [start, _] -> start end) |> Enum.min()

    output_min = output_intervals |> Enum.map(fn [start, _] -> start end) |> Enum.min()

    min = min(input_min_with_identity, output_min)

    min
  end

  def pipe_seed_intervals_into_mappers(seed_intervals, mappers) do
    [current_mapper | rest_mappers] = mappers

    output_intervals = resolve_seed_intervals_with_mapper(seed_intervals, current_mapper)

    if rest_mappers == [] do
      output_intervals
    else
      pipe_seed_intervals_into_mappers(output_intervals, rest_mappers)
    end
  end

  @doc """
  Given a list of input ranges (start, count), and a mapper, returns the output ranges (start, count).

  TODO: This can have some logic for merging neighboring output ranges.

  Examples:

      iex> AOC2023.FertilizerPart2.resolve_seed_intervals_with_mapper([[2, 4], [5, 10]], [%{from: [2, 4], to: [1, 3]}, %{from: [5, 10], to: [105, 110]}])
      # 2-4 maps to 1-3, 5-10 maps to 105-110
      [[1, 3], [105, 110]]
  """
  def resolve_seed_intervals_with_mapper(seed_intervals, mapper) do
    mapped_output_ranges =
      Enum.reduce(seed_intervals, [], fn input_range, acc ->
        acc ++ resolve_input_range_with_mapper(input_range, mapper)
      end)

    mapped_output_ranges
  end

  @doc """
  TODO: implement

  """
  def fill_with_identity_input_ranges(seed_intervals, mapper) do
    sorted_mapper =
      mapper
      |> Enum.sort_by(fn range_map -> Enum.at(range_map[:from], 0) end)

    sorted_input_ranges = seed_intervals |> Enum.sort_by(fn [start, _] -> start end)

    IO.puts("Sorted input ranges: #{inspect(sorted_input_ranges, charlists: :as_lists)}")

    input_start = Enum.at(Enum.at(sorted_input_ranges, 0), 0)
    input_end = Enum.at(Enum.at(sorted_input_ranges, -1), 1)

    IO.puts("Input start: #{input_start}, input end: #{input_end}")

    sorted_input_ranges
    |> Enum.reduce([], fn [input_start, input_end], acc ->
      sorted_mapper
      |> Enum.reduce(acc, fn range_map, acc ->
        common_interval =
          get_common_interval(range_map[:from], [input_start, input_end])

        if common_interval == nil do
          acc
        else
          [mapped_start, mapped_end] =
            get_mapped_start_end(common_interval, range_map)

          acc ++ [[mapped_start, mapped_end]]
        end
      end)
    end)
  end

  @doc """
  Given a input range (start, count), and a mapper, returns the output ranges (start, count).

  Examples:

      iex> AOC2023.FertilizerPart2.resolve_input_range_with_mapper([2, 4], [%{from: [2, 4], to: [1, 3]}])
      [[1, 3]]

      iex> AOC2023.FertilizerPart2.resolve_input_range_with_mapper([3, 10], [%{from: [2, 4], to: [1, 3]}, %{from: [5, 10], to: [105, 110]}])
      # 3-4 maps to 2-3, 5-10 maps to 105-110
      [[2, 3], [105, 110]]
  """
  def resolve_input_range_with_mapper([input_start, input_end], mapper) do
    Enum.reduce(mapper, [], fn range_map, acc ->
      common_interval =
        get_common_interval(range_map[:from], [input_start, input_end])

      if common_interval == nil do
        acc
      else
        [mapped_start, mapped_end] =
          get_mapped_start_end(common_interval, range_map)

        acc ++ [[mapped_start, mapped_end]]
      end
    end)
  end

  @spec get_mapped_start_end([number(), ...], %{
          :from => [...],
          :to => [...],
          optional(any()) => any()
        }) :: [number(), ...]
  @doc """
  For a given input range guaranteed to be within a range map, returns the corresponding output range.
  """
  def get_mapped_start_end(
        [input_start, input_end],
        %{from: [from_start, _], to: [to_start, _]}
      ) do
    diff = to_start - from_start

    [input_start + diff, input_end + diff]
  end

  def get_common_interval([a_start, a_end], [b_start, b_end]) do
    if b_start > a_end or a_start > b_end do
      nil
    else
      [max(a_start, b_start), min(a_end, b_end)]
    end
  end

  @doc """
  Returns a list of maps, each map representing a mapping from a source to a destination.

  Examples:

      iex> AOC2023.FertilizerPart2.create_all_mappers(["", "", "map:", "1 2 3", "4 5 6", "", "map:", "7 8 9", "10 11 12"])
      [[%{from: [2, 4], to: [1, 3]}, %{from: [5, 10], to: [4, 9]}], [%{from: [8, 16], to: [7, 15]}, %{from: [11, 22], to: [10, 21]}]]
  """
  def create_all_mappers(lines) do
    lines
    |> get_mapper_lines()
    |> Enum.reduce([], fn mapper_lines, acc ->
      acc ++ [Enum.map(mapper_lines, fn line -> create_range_map(line) end)]
    end)
  end

  @doc """
  Returns a list of list of lines, each inner list representing the lines of a mapper.

  Examples:

      iex> AOC2023.FertilizerPart2.get_mapper_lines(["", "", "map:", "1 2 3", "4 5 6", "", "map:", "7 8 9", "10 11 12"])
      [["1 2 3", "4 5 6"], ["7 8 9", "10 11 12"]]
  """
  def get_mapper_lines(lines) do
    lines
    |> Enum.drop(2)
    |> Enum.filter(fn line -> !String.contains?(line, "map:") end)
    |> Enum.chunk_by(fn line -> line != "" end)
    |> Enum.reject(fn chunk -> chunk == [""] end)
  end

  @doc """
  Returns a list of maps, each map representing a mapping from a source to a destination.

  Examples:

  iex> AOC2023.FertilizerPart2.create_range_map("1 2 3")
  %{from: [2, 4], to: [1, 3]}
  """
  def create_range_map(line) do
    [dest, src, count] =
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    %{from: [src, src + count - 1], to: [dest, dest + count - 1]}
  end

  @doc """
  Returns a list of seeds.

  Examples:

      iex> AOC2023.FertilizerPart2.get_seed_intervals(["seeds: 79 2 3 4"])
      [[79, 80], [3, 6]]
  """
  def get_seed_intervals(lines) do
    [seed_line | _] = lines

    seed_numbers =
      seed_line
      |> String.split(": ")
      |> List.last()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    Enum.chunk_every(seed_numbers, 2)
    |> Enum.map(fn [start, count] -> [start, start + count - 1] end)
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
