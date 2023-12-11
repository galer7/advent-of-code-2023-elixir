# Problem text: https://adventofcode.com/2023/day/1

defmodule AOC2023.Trebuchet do
  def solve do
    calibration_doc_lines = read_file(relative_from_here("input.txt"))

    calibration_doc_lines
    |> Enum.map(&get_calibration_value/1)
    |> Enum.sum()
  end

  defp get_calibration_value(line) do
    first_search_result =
      Regex.named_captures(
        ~r/^[^\d]*(?<first_digit>[\d]{1}).*(?<last_digit>[\d]{1})[^\d]*$/,
        line
      )

    case first_search_result do
      nil ->
        %{"digit" => digit} = get_only_digit_from_string(line)
        {result, _} = Integer.parse("#{digit}#{digit}")

        result

      _ ->
        %{"first_digit" => first_digit, "last_digit" => last_digit} = first_search_result
        {result, _} = Integer.parse("#{first_digit}#{last_digit}")

        result
    end
  end

  defp get_only_digit_from_string(string) do
    result =
      Regex.named_captures(
        ~r/^[^\d]*(?<digit>[\d]{1})[^\d]*$/,
        string
      )

    result
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
