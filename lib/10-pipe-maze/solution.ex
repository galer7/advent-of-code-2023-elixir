# Problem text: https://adventofcode.com/2023/day/10

defmodule AOC2023.PipeMaze do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    {starting_x, starting_y} = get_starting_position_coords(lines)

    path = traverse_pipes(lines, {starting_x, starting_y}, nil, [])

    compute_path_node_scores(path) |> Enum.max()
  end

  def compute_path_node_scores(path) do
    path_loop_length = Enum.count(path)
    furthest_node_idx = (path_loop_length / 2) |> round()

    0..furthest_node_idx
    |> Enum.map(fn idx ->
      if idx <= furthest_node_idx do
        idx
      else
        path_loop_length - idx
      end
    end)
  end

  @doc """
  Traverse the pipe maze. Return the path taken.

  Note: Starting position is included at both ends of the path.

  Examples:
      iex> AOC2023.PipeMaze.traverse_pipes(["S7-", "LJ-", "..."], {0, 0}, nil, [])
      [{0, 0}, {0, 1}, {1, 1}, {0, 1}, {0, 0}]
  """
  def traverse_pipes(lines, current_coords, prev_coords, path) do
    next_move = get_next_move(lines, current_coords, prev_coords)

    if next_move.sym == "S" do
      path ++ [current_coords]
    else
      next_coords = {next_move.x, next_move.y}
      traverse_pipes(lines, next_coords, current_coords, path ++ [current_coords])
    end
  end

  @doc """
  Get next move from current position.

  Examples:
      iex> AOC2023.PipeMaze.get_next_move(["S--", "F--", "L--"], {0, 0}, nil)
      %{x: 0, y: 1, sym: "-"}

      iex> AOC2023.PipeMaze.get_next_move(["S--", "F--", "L--"], {0, 1}, {0, 0})
      %{x: 0, y: 2, sym: "-"}

      iex> AOC2023.PipeMaze.get_next_move(["S--", "L--", "F--"], {0, 0}, nil)
      # Order is left, right, top, bottom
      %{x: 1, y: 0, sym: "-"}
  """
  def get_next_move(lines, current_coords, previous_coords) do
    {x, y} = current_coords

    possible_moves = get_possible_moves(lines, x, y)

    %{x: next_x, y: next_y, sym: next_sym} =
      possible_moves
      |> Enum.filter(fn move ->
        case previous_coords do
          nil -> if move.sym == "S", do: false, else: true
          {prev_x, prev_y} -> move.x != prev_x || move.y != prev_y
        end
      end)
      |> Enum.at(0)

    next_move =
      %{x: next_x, y: next_y, sym: next_sym}

    next_move
  end

  @doc """
  Get %{x, y, sym} of possible moves from current position.

  Examples:
      iex> AOC2023.PipeMaze.get_possible_moves(["S--", "F--", "L--"], 0, 0)
      [%{x: 0, y: 1, sym: "-"}]

      iex> AOC2023.PipeMaze.get_possible_moves(["S--", "F--", "L--"], 0, 1)
      [%{x: 0, y: 0, sym: "S"}, %{x: 0, y: 2, sym: "-"}]

      iex> AOC2023.PipeMaze.get_possible_moves(["...", ".S.", "..."], 1, 1)
      []
  """
  def get_possible_moves(lines, x, y) do
    %{left: left, right: right, top: top, bottom: bottom} = get_neighboring_symbols(lines, x, y)
    current_symbol = get_from_lines(lines, x, y)

    left_symbols = ["L", "F", "-", "S"]
    right_symbols = ["J", "7", "-", "S"]
    top_symbols = ["|", "7", "F", "S"]
    bottom_symbols = ["|", "J", "L", "S"]

    can_go_left? =
      Enum.member?(left_symbols, left) and
        Enum.member?(
          right_symbols,
          current_symbol
        )

    can_go_right? =
      Enum.member?(right_symbols, right) and
        Enum.member?(
          left_symbols,
          current_symbol
        )

    can_go_up? = Enum.member?(top_symbols, top) and Enum.member?(bottom_symbols, current_symbol)

    can_go_down? =
      Enum.member?(bottom_symbols, bottom) and Enum.member?(top_symbols, current_symbol)

    [
      if(can_go_left?, do: %{x: x - 1, y: y, sym: left}, else: nil),
      if(can_go_right?, do: %{x: x + 1, y: y, sym: right}, else: nil),
      if(can_go_up?, do: %{x: x, y: y - 1, sym: top}, else: nil),
      if(can_go_down?,
        do: %{x: x, y: y + 1, sym: bottom},
        else: nil
      )
    ]
    |> Enum.filter(fn val -> val != nil end)
  end

  def get_neighboring_symbols(lines, x, y) do
    %{h: height, w: width} = get_lines_dims(lines)

    left = if x == 0, do: nil, else: get_from_lines(lines, x - 1, y)

    right =
      if x == width - 1, do: nil, else: get_from_lines(lines, x + 1, y)

    top = if y == 0, do: nil, else: get_from_lines(lines, x, y - 1)

    bottom =
      if y == height - 1, do: nil, else: get_from_lines(lines, x, y + 1)

    %{left: left, right: right, top: top, bottom: bottom}
  end

  def get_from_lines(lines, x, y) do
    Enum.at(Enum.at(lines, y) |> String.split("", trim: true), x)
  end

  def get_lines_dims(lines) do
    %{h: Enum.count(lines), w: String.length(Enum.at(lines, 0))}
  end

  def get_starting_position_coords(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn {line, y}, _ ->
      x = Enum.find_index(line |> String.split("", trim: true), fn char -> char == "S" end)

      if x do
        {:halt, {x, y}}
      else
        {:cont, nil}
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
