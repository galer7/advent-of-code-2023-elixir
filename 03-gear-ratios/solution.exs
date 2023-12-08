# Problem text: https://adventofcode.com/2023/day/3

# Optimizations:
# -

defmodule GearRatios do
  def solve do
    IO.puts("[solve] Starting")

    path = relative_from_here("input.txt")

    lines =
      read_file(path)
      |> Enum.filter(fn line ->
        line != ""
      end)

    part_numbers = get_all_part_numbers(lines)

    IO.inspect(part_numbers, limit: :infinity)

    result =
      Enum.reduce(part_numbers, 1, fn number, acc ->
        number + acc
      end)

    IO.puts("[solve] Result: #{result}")
    IO.puts("[solve] Done")
  end

  # For each line, keep current number formation, and then check if is near a symbol
  defp get_all_part_numbers(rows) do
    rows
    |> Enum.with_index()
    |> Enum.map(fn {row, y0} ->
      good_numbers_from_row =
        row
        |> get_numbers_with_x0_from_row(y0)
        |> Enum.filter(fn {number, x0} ->
          is_number_part_number?(number, rows, x0, y0)
        end)
        |> Enum.map(fn {number, _} ->
          number
        end)

      good_numbers_from_row
    end)
    |> List.flatten()
  end

  defp get_numbers_with_x0_from_row(row, y_row) do
    IO.puts("[#{y_row}] Row: #{row}")

    pattern = ~r/\d+/
    matches = Regex.scan(pattern, row)
    matches_indexes = Regex.scan(pattern, row, return: :index)

    result =
      matches
      |> Enum.with_index()
      |> Enum.map(fn {[match_str], i} ->
        [{match_index, _}] = Enum.at(matches_indexes, i)

        case Integer.parse(match_str) do
          {number, _} ->
            {number, match_index}

          :error ->
            raise "Error parsing number: #{match_str}"
        end
      end)

    result
  end

  # x0 and y0 is the location from which the number starts in the matrix
  defp is_number_part_number?(number, rows, x0, y0) do
    number_len = number |> Integer.to_string() |> String.length()
    matrix_h = length(rows)
    matrix_w = rows |> Enum.at(0) |> String.length()

    bounding_box_points = get_bounding_box_points(number_len, matrix_h, matrix_w, x0, y0)

    Enum.any?(bounding_box_points, fn {x, y} ->
      is_symbol?(String.at(Enum.at(rows, y), x))
    end)
  end

  defp get_bounding_box_points(number_len, matrix_h, matrix_w, x0, y0) do
    x_left = x0 - 1
    x_right = x0 + number_len
    y_top = y0 - 1
    y_bottom = y0 + 1

    top_line =
      if y_top < 0 do
        []
      else
        Enum.map(x_left..x_right, fn x ->
          {x, y_top}
        end)
      end

    bottom_line =
      if y_bottom >= matrix_h do
        []
      else
        Enum.map(x_left..x_right, fn x ->
          {x, y_bottom}
        end)
      end

    left_line =
      if x_left < 0 do
        []
      else
        [{x_left, y0}]
      end

    right_line =
      if x_right >= matrix_w do
        []
      else
        [{x_right, y0}]
      end

    top_line ++ bottom_line ++ left_line ++ right_line
  end

  defp is_symbol?(char) do
    case char do
      nil ->
        false

      _ ->
        Regex.match?(~r/[^0-9\.]/, char)
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

GearRatios.solve()
