# Problem text: https://adventofcode.com/2023/day/2

defmodule AOC2023.CubeConundrumPart2 do
  def solve do
    games = read_file(relative_from_here("input.txt"))

    do_solve(games)
  end

  def do_solve(games) do
    games
    |> Enum.map(fn game ->
      game_sets = get_games_sets(game)
      optimal_cubes = get_optimal_cubes_for_game(game_sets)
      power = compute_power_of_optimal_cubes(optimal_cubes)

      power
    end)
    |> Enum.sum()
  end

  @doc """
  Parse a line of the calibration document.

  Returns the first and last digit (as a string) of the calibration value.

  Examples:

      iex> AOC2023.CubeConundrumPart2.get_games_sets("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
      [%{blue: 3, red: 4}, %{red: 1, green: 2, blue: 6}, %{green: 2}]
  """
  def get_games_sets(game) do
    game
    |> String.split(": ", trim: true)
    |> List.last()
    |> String.split("; ", trim: true)
    |> Enum.map(&parse_game_set/1)
  end

  @doc """
  Get optimal set of cubes for for all game sets of a game. Optimal means the
  set of cubes that has the least amount of cubes which can suffice for all
  game sets.

  Returns a map of color to count.

  Examples:

      # Game 1:
      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{blue: 3, red: 4}, %{red: 1, green: 2, blue: 6}, %{green: 2}])
      %{blue: 6, red: 4, green: 2}

      # Game 2:
      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{blue: 1, green: 2}, %{green: 3, blue: 4, red: 1}, %{green: 1, blue: 1}])

      # Game 3:
      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{green: 8, blue: 6, red: 20}, %{blue: 5, red: 4, green: 13}, %{green: 5, red: 1}])

      # Game 4:
      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{green: 1, red: 3, blue: 6}, %{green: 3, red: 6}, %{green: 3, blue: 15, red: 14}])

      # Game 5:
      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{red: 6, blue: 1, green: 3}, %{blue: 2, red: 1, green: 2}])

      iex> AOC2023.CubeConundrumPart2.get_optimal_cubes_for_game([%{red: 100}, %{green: 100}, %{blue: 100}])
      %{blue: 100, green: 100, red: 100}
  """
  def get_optimal_cubes_for_game(game_sets) do
    Enum.reduce(game_sets, %{}, fn game_set, acc ->
      Enum.reduce(game_set, acc, fn {color, count}, acc ->
        case Map.get(acc, color) do
          nil ->
            Map.put(acc, color, count)

          existing_count ->
            if count > existing_count do
              Map.put(acc, color, count)
            else
              acc
            end
        end
      end)
    end)
  end

  @doc """
  Get power for optimal set of cubes.

  Examples:

      iex> AOC2023.CubeConundrumPart2.compute_power_of_optimal_cubes(%{blue: 6, red: 4, green: 2})
      48

      iex> AOC2023.CubeConundrumPart2.compute_power_of_optimal_cubes(%{blue: 100, green: 100, red: 100})
      1000000
  """
  def compute_power_of_optimal_cubes(optimal_cubes) do
    Enum.reduce(optimal_cubes, 1, fn {_color, count}, acc ->
      acc * count
    end)
  end

  @doc """
  Parse a game set.

  Examples:

      iex> AOC2023.CubeConundrumPart2.parse_game_set("3 blue, 4 red")
      %{blue: 3, red: 4}

      iex> AOC2023.CubeConundrumPart2.parse_game_set("1 red, 2 green, 6 blue")
      %{red: 1, green: 2, blue: 6}

      iex> AOC2023.CubeConundrumPart2.parse_game_set("2 green")
      %{green: 2}
  """
  def parse_game_set(game_set) do
    game_set
    |> String.split(",", trim: true)
    |> Enum.map(&parse_game_cube/1)
    |> Enum.reduce(%{}, fn {count, color}, acc ->
      Map.put(acc, color, count)
    end)
  end

  @doc """
  Parse a game cube.

  Examples:

      iex> AOC2023.CubeConundrumPart2.parse_game_cube("3 blue")
      {3, :blue}

      iex> AOC2023.CubeConundrumPart2.parse_game_cube("4 red")
      {4, :red}

      iex> AOC2023.CubeConundrumPart2.parse_game_cube("2 green")
      {2, :green}
  """
  def parse_game_cube(game_cube) do
    [count, color] = String.split(game_cube, " ", trim: true)
    {String.to_integer(count), String.to_atom(color)}
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
