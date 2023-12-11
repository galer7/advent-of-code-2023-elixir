# Problem text: https://adventofcode.com/2023/day/2

defmodule AOC2023.CubeConundrum do
  def solve do
    games = read_file(relative_from_here("input.txt"))

    do_solve(games)
  end

  def do_solve(games) do
    goal_game_cubes = %{
      red: 12,
      green: 13,
      blue: 14
    }

    games
    |> Enum.map(fn game ->
      game_id = get_game_id(game)
      game_sets = get_games_sets(game)

      if check_if_game_is_valid(game_sets, goal_game_cubes) do
        game_id
      else
        nil
      end
    end)
    |> Enum.filter(&(&1 != nil))
    |> Enum.sum()
  end

  @doc """
  Parse a line of the calibration document.

  Returns the first and last digit (as a string) of the calibration value.

  Examples:

      iex> AOC2023.CubeConundrum.get_games_sets("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
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
  Check if game is valid, meaning all game sets of the game are valid.

  Returns true if all game sets are valid, false otherwise.

  Examples:

      iex> AOC2023.CubeConundrum.check_if_game_is_valid([%{blue: 3, red: 4}, %{red: 1, green: 2, blue: 6}, %{green: 2}], %{red: 12, green: 13, blue: 14})
      true

      iex> AOC2023.CubeConundrum.check_if_game_is_valid([%{blue: 3, red: 4}, %{red: 1, green: 2, blue: 6}, %{green: 100}], %{red: 12, green: 13, blue: 14})
      false
  """
  def check_if_game_is_valid(all_game_sets, goal_game_cubes) do
    Enum.all?(all_game_sets, fn game_set ->
      check_if_game_set_is_valid(game_set, goal_game_cubes)
    end)
  end

  def get_game_id(game) do
    game
    |> String.split(": ", trim: true)
    |> List.first()
    |> String.split(" ", trim: true)
    |> List.last()
    |> String.to_integer()
  end

  @doc """
  Check if game set is valid, meaning all game cubes of the game set are valid.

  Returns true if all game cubes are valid, false otherwise.

  Examples:

      iex> AOC2023.CubeConundrum.check_if_game_set_is_valid(%{blue: 3, red: 4}, %{red: 12, green: 13, blue: 14})
      true

      iex> AOC2023.CubeConundrum.check_if_game_set_is_valid(%{blue: 3, red: 100}, %{red: 12, green: 13, blue: 14})
      false
  """
  def check_if_game_set_is_valid(game_set, goal_game_cubes) do
    Enum.all?(goal_game_cubes, fn {color, count} ->
      count >= Map.get(game_set, color, 0)
    end)
  end

  @doc """
  Parse a game set.

  Examples:

      iex> AOC2023.CubeConundrum.parse_game_set("3 blue, 4 red")
      %{blue: 3, red: 4}

      iex> AOC2023.CubeConundrum.parse_game_set("1 red, 2 green, 6 blue")
      %{red: 1, green: 2, blue: 6}

      iex> AOC2023.CubeConundrum.parse_game_set("2 green")
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

      iex> AOC2023.CubeConundrum.parse_game_cube("3 blue")
      {3, :blue}

      iex> AOC2023.CubeConundrum.parse_game_cube("4 red")
      {4, :red}

      iex> AOC2023.CubeConundrum.parse_game_cube("2 green")
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
