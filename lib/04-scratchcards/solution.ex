# Problem text: https://adventofcode.com/2023/day/4

defmodule AOC2023.ScratchCards do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    lines
    |> Enum.map(fn line ->
      winning_numbers = get_winning_numbers(line)
      your_numbers = get_your_numbers(line)

      winning_numbers_count =
        Enum.count(your_numbers, fn number ->
          find_if_number_is_winning(number, winning_numbers)
        end)

      if winning_numbers_count == 0 do
        0
      else
        2 ** (winning_numbers_count - 1)
      end
    end)
    |> Enum.sum()
  end

  def find_if_number_is_winning(number, winning_numbers) do
    Enum.member?(winning_numbers, number)
  end

  def get_winning_numbers(line) do
    line
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split(" | ")
    |> Enum.at(0)
    |> String.split(" ", trim: true)
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  def get_your_numbers(line) do
    line
    |> String.split(": ")
    |> Enum.at(1)
    |> String.split(" | ")
    |> Enum.at(1)
    |> String.split(" ", trim: true)
    |> Enum.map(fn x -> String.to_integer(x) end)
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
