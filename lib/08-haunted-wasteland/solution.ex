defmodule AOC2023.HauntedWastelandPart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    instructions = get_lr_instructions(lines)
    map = get_map(lines)

    acc = %{idx: 0, current_node: "AAA", count: 0}

    %{count: count} =
      while_loop(
        instructions,
        map,
        fn acc ->
          acc.current_node == "ZZZ"
        end,
        acc
      )

    count
  end

  def while_loop(instructions, map, cond_fn, acc) do
    if cond_fn.(acc) do
      acc
    else
      next_move = (Enum.at(instructions, acc.idx) == "L" && :left) || :right

      new_idx = rem(acc.idx + 1, length(instructions))

      current_node_next_moves = Map.get(map, acc.current_node)
      next_node = Map.get(current_node_next_moves, next_move)

      new_acc = %{idx: new_idx, current_node: next_node, count: acc.count + 1}

      while_loop(instructions, map, cond_fn, new_acc)
    end
  end

  def get_lr_instructions(lines) do
    lines
    |> Enum.at(0)
    |> String.split("", trim: true)
  end

  def get_map(lines) do
    lines
    |> Enum.drop(2)
    |> Enum.reduce(%{}, fn line, acc ->
      [from, to] = String.split(line, " = ", trim: true)
      [left, right] = String.split(to, ", ", trim: true)
      [left] = String.split(left, "(", trim: true)
      [right] = String.split(right, ")", trim: true)

      Map.put(acc, from, %{left: left, right: right})
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
