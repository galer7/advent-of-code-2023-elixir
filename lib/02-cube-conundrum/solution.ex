# Problem text: https://adventofcode.com/2023/day/2

# Issues that I faced:
# - I don't know what return type format to use for the functions. Function names are not enough pretty good to understand what they do.

defmodule AOC2023.CubeConundrum do
  def solve do
    games = read_file(relative_from_here("input.txt"))

    map_max_cubes =
      %{"red" => 12, "green" => 13, "blue" => 14}

    Enum.reduce(games, 0, fn line, acc ->
      case String.trim(line) do
        "" ->
          acc

        _ ->
          [game_id_str, game_line] = String.split(line, ":")

          subsets =
            get_array_of_subset_maps(game_line)

          is_current_game_valid =
            is_game_valid(subsets, map_max_cubes)

          case is_current_game_valid do
            true ->
              {game_id, _} = String.split(game_id_str, " ") |> List.last() |> Integer.parse()

              acc + game_id

            false ->
              acc
          end
      end
    end)
  end

  # returns [%{red: count_red, green: count_green, blue: count_blue}, %{red: count_red_2, green: count_green_2, blue: count_blue_2}]
  defp get_array_of_subset_maps(game_line) do
    game_line
    |> get_subset_str()
    |> Enum.map(&get_cubes_str/1)
    |> Enum.map(fn cubes_str ->
      cubes_str
      |> Enum.map(&get_cube_count_and_color/1)
      |> Enum.map(fn [count_str, color_str] ->
        {count, _} = Integer.parse(count_str)

        {color_str, count}
      end)
      |> Enum.into(%{})
    end)
  end

  # returns ["count_red red, count_green green, count_blue blue", "count_red_2 red, count_green_2 green, count_blue_2 blue"]
  defp get_subset_str(game_line) do
    game_line
    |> String.split(";", trim: true)
  end

  # returns ["count_red red", "count_green green", "count_blue blue"]
  def get_cubes_str(subset_str) do
    subset_str
    |> String.split(",", trim: true)
  end

  # returns ["count_red", "red"]
  def get_cube_count_and_color(cube_str) do
    cube_str
    |> String.split(" ", trim: true)
  end

  # subsets is of type [%{red: R1, green: G1, blue: B1}, %{red: R2, green: G2, blue: B2}]
  defp is_game_valid(subsets, map_max_cubes) do
    Enum.all?(subsets, fn subset ->
      is_subset_valid(subset, map_max_cubes)
    end)
  end

  # subset is of type %{red: 1, green: 2, blue: 3}
  defp is_subset_valid(subset, map_max_cubes) do
    Enum.all?(subset, fn {color, count} ->
      case Map.get(map_max_cubes, color) do
        nil ->
          raise "Invalid color: #{color}"

        max_cubes ->
          count <= max_cubes
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
