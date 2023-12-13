# Problem text: https://adventofcode.com/2023/day/4

defmodule AOC2023.ScratchCardsPart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    cards_memoization_map =
      lines
      |> Enum.reverse()
      |> Enum.reduce(%{}, fn line, acc ->
        card_id = get_card_id(line)
        winning_numbers = get_winning_numbers(line)
        your_numbers = get_your_numbers(line)

        current_card_wins_count =
          your_numbers
          |> Enum.count(fn number ->
            find_if_number_is_winning(number, winning_numbers)
          end)

        won_cards_by_current =
          if current_card_wins_count == 0 do
            []
          else
            (card_id + 1)..min(card_id + current_card_wins_count, length(lines))
            |> Enum.to_list()
          end

        Map.put(acc, card_id, %{
          card_id: card_id,
          memo:
            1 +
              (won_cards_by_current
               |> Enum.map(fn card_id -> Map.get(acc, card_id).memo end)
               |> Enum.sum())
        })
      end)

    cards_memoization_map |> Enum.reduce(0, fn {_, card}, acc -> acc + card.memo end)
  end

  def find_if_number_is_winning(number, winning_numbers) do
    Enum.member?(winning_numbers, number)
  end

  def get_card_id(line) do
    line
    |> String.split(": ")
    |> Enum.at(0)
    |> String.split(" ", trim: true)
    |> Enum.at(1)
    |> String.to_integer()
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
