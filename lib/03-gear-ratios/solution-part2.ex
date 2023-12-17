# Problem text: https://adventofcode.com/2023/day/3

defmodule AOC2023.GearRatiosPart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    symbols = get_all_symbols(lines)
    numbers = get_all_numbers(lines)

    symbols
    |> Enum.reduce(0, fn sym, acc ->
      part_numbers_for_symbol = get_part_numbers_for_symbol(sym, numbers)

      if is_symbol_a_gear?(part_numbers_for_symbol) do
        acc +
          (part_numbers_for_symbol
           |> Enum.map(fn %{value: value} -> value end)
           |> Enum.product())
      else
        acc
      end
    end)
  end

  def is_symbol_a_gear?(part_numbers_for_symbol) do
    length(part_numbers_for_symbol) == 2
  end

  @doc """
  Given a symbol and a list of numbers, return the numbers that are on the same
  line or on neighboring lines.
  """
  def get_part_numbers_for_symbol(%{x: sym_x, y: sym_y}, numbers) do
    numbers
    |> Enum.filter(fn %{y: num_y} ->
      is_on_neighboring_lines? = abs(num_y - sym_y) == 1
      is_on_same_line? = num_y == sym_y

      is_on_neighboring_lines? or is_on_same_line?
    end)
    |> Enum.filter(fn %{x: num_x, value: num_value} ->
      num_length = num_value |> Integer.to_string() |> String.length()

      number_line = num_x..(num_x + num_length - 1) |> Enum.to_list()
      sym_line = (sym_x - 1)..(sym_x + 1) |> Enum.to_list()

      Enum.any?(number_line, fn x -> Enum.member?(sym_line, x) end)
    end)
  end

  @doc """
  Given a list of lines, return a list of all symbols and their index in the line

  Examples:

      iex> AOC2023.GearRatios.get_all_symbols([".2.*.999.", "123.456#789"])
      [%{value: "*", x: 3, y: 0}, %{value: "#", x: 7, y: 1}]
  """

  def get_all_symbols(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, yi}, acc ->
      symbols_for_line = get_symbols_for_line(line)

      acc ++
        Enum.map(symbols_for_line, fn {value, xi} ->
          %{value: value, x: xi, y: yi}
        end)
    end)
  end

  def get_all_numbers(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, yi}, acc ->
      numbers_for_line = get_number_for_line(line)

      acc ++
        Enum.map(numbers_for_line, fn {value, xi} ->
          %{value: value, x: xi, y: yi}
        end)
    end)
  end

  @doc """
  Given a line, return the symbols and their index in the line if they are
  present.

  Examples:

      iex> AOC2023.GearRatios.get_symbols_for_line(".2.*.999.")
      [{"*", 3}]

      iex> AOC2023.GearRatios.get_symbols_for_line("12..*..3#...4")
      [{"*", 4}, {"#", 8}]

      iex> AOC2023.GearRatios.get_symbols_for_line("...1.2.3.4.5...")
      []
  """
  def get_symbols_for_line(line) do
    symbol_re = ~r/[^0-9\.]/

    matches_index =
      Regex.scan(symbol_re, line, return: :index) |> List.flatten()

    matches_value = Regex.scan(symbol_re, line) |> List.flatten()

    result =
      Enum.zip(matches_value, matches_index)
      |> Enum.reduce([], fn {value, {index, _length}}, acc ->
        acc ++ [{value, index}]
      end)

    result
  end

  @doc """
  Given a line, return the number and its index in the line if it is present.

  Examples:

      iex> AOC2023.GearRatios.get_number_for_line("123.456#789")
      [{123, 0}, {456, 4}, {789, 8}]
  """
  def get_number_for_line(line) do
    number_re = ~r/[0-9]+/

    matches_index =
      Regex.scan(number_re, line, return: :index) |> List.flatten()

    matches_value = Regex.scan(number_re, line) |> List.flatten()

    Enum.zip(matches_value, matches_index)
    |> Enum.reduce([], fn {value, {index, _length}}, acc ->
      acc ++ [{value |> String.to_integer(), index}]
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
