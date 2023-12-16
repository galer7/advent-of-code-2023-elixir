# Problem text: https://adventofcode.com/2023/day/9

defmodule AOC2023.MirageMaintenancePart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    history_entries = get_history_entries_from_lines(lines)

    history_entries
    |> Enum.map(fn history_entry ->
      get_extrapolated_value_from_history_entry(history_entry, [])
    end)
    |> Enum.sum()
  end

  def get_history_entries_from_lines(lines) do
    lines
    |> Enum.map(fn line ->
      line |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end)
  end

  @doc """
  Get extrapolated value from history entry

  Examples:
      iex> AOC2023.MirageMaintenancePart2.get_extrapolated_value_from_history_entry([1, 2, 3, 4], [])
      # level 0:  1 2 3 4
      # level -1:  1 1 1
      # level -2:   0 0
      # so, extrapolated is:
      #  0 1 2 3 4
      #   1 1 1 1
      #    0 0 0
      0

      iex> AOC2023.MirageMaintenancePart2.get_extrapolated_value_from_history_entry([1, 3, 6, 10, 15, 21], [])
      # level 0:  1 3 6  10  15  21
      # level -1:  2 3  4   5  6
      # level -2:   1 1  1   1
      # level -3:    0 0  0
      # so, extrapolated is:
      #  0 1 3 6 10 15  21
      #   1 2 3 4  5  6
      #    1 1 1 1  1
      #     0 0 0  0
      0
  """

  def get_extrapolated_value_from_history_entry(current_history_seq, history_seqs) do
    # IO.puts(
    #   "current_history_seq: #{inspect(current_history_seq)}, history_seqs: #{inspect(history_seqs)}"
    # )

    # The all-zeros sequence is not present in the history_seqs
    is_current_seq_all_zeros? = Enum.all?(current_history_seq, fn value -> value == 0 end)

    if is_current_seq_all_zeros? do
      Enum.reverse(history_seqs)
      |> Enum.reduce(0, fn seq, acc ->
        first_value_from_seq = Enum.at(seq, 0)
        first_value_from_seq - acc
      end)
    else
      next_history_seq =
        current_history_seq
        |> Enum.with_index()
        |> Enum.reduce([], fn {value, idx}, acc ->
          if idx == 0 do
            acc
          else
            prev_value = Enum.at(current_history_seq, idx - 1)
            acc ++ [value - prev_value]
          end
        end)

      get_extrapolated_value_from_history_entry(
        next_history_seq,
        history_seqs ++ [current_history_seq]
      )
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
