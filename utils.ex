defmodule Utils do
  def write_file(path, content) do
    case File.write(path, content) do
      :ok ->
        :ok

      {:error, reason} ->
        raise "Error writing file: #{reason}"
    end
  end
end
