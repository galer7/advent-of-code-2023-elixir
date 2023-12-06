defmodule Trebuchet do
  def solve do
    input_lines = read_file(relative_from_here("input.txt"))

    input_lines
    |> Enum.map(&get_first_and_last_digit_from_string/1)
    |> Enum.sum()
    # prints result to stdout
    |> IO.puts()
  end

  defp get_first_and_last_digit_from_string(string) do
    IO.puts("[get_first_and_last_digit_from_string] string: #{string}")

    first_search_result =
      Regex.named_captures(
        ~r/^[^\d]*(?<first_digit>[\d]{1}).*(?<last_digit>[\d]{1})[^\d]*$/,
        string
      )

    IO.puts(
      "[get_first_and_last_digit_from_string] first_search_result: #{inspect(first_search_result)}"
    )

    case first_search_result do
      nil ->
        %{"digit" => digit} = get_only_digit_from_string(string)
        {result, _} = Integer.parse("#{digit}#{digit}")

        IO.puts("[get_first_and_last_digit_from_string] result: #{inspect(result)}")
        result

      _ ->
        %{"first_digit" => first_digit, "last_digit" => last_digit} = first_search_result
        {result, _} = Integer.parse("#{first_digit}#{last_digit}")

        IO.puts("[get_first_and_last_digit_from_string] result: #{inspect(result)}")
        result
    end
  end

  defp get_only_digit_from_string(string) do
    IO.puts("[get_only_digit_from_string] string: #{string}")

    result =
      Regex.named_captures(
        ~r/^[^\d]*(?<digit>[\d]{1})[^\d]*$/,
        string
      )

    IO.puts("[get_only_digit_from_string] result: #{inspect(result)}")
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

  defp write_file(path, content) do
    IO.puts("[write_file] Writing to #{path}")

    case File.write(path, content) do
      :ok ->
        IO.puts("[write_file] Wrote #{content |> String.length()} bytes")

      {:error, reason} ->
        raise "Error writing file: #{reason}"
    end
  end

  defp relative_from_here(path) do
    new_path = Path.join(__DIR__, path)
    new_path
  end
end

Trebuchet.solve()
