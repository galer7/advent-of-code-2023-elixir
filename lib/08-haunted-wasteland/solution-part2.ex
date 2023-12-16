# Problem text: https://adventofcode.com/2023/day/8

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
    starting_nodes = get_starting_nodes(map)

    starting_nodes
    |> Enum.map(fn starting_node ->
      acc = %{idx: 0, current_node: starting_node, count: 0}

      %{count: count} =
        while_loop(
          instructions,
          map,
          fn acc ->
            String.ends_with?(acc.current_node, "Z")
          end,
          acc
        )

      count
    end)
    |> Enum.reduce(1, fn count, acc ->
      lcm(count, acc)
    end)
  end

  def lcm(a, b) do
    (a * b / gcd(a, b)) |> trunc()
  end

  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))

  def get_starting_nodes(map) do
    map
    |> Map.keys()
    |> Enum.filter(fn node ->
      String.ends_with?(node, "A")
    end)
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
