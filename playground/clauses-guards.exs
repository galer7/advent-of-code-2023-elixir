x = 1

x =
  case {1, 2, 3} do
    {1, x, 3} when x > 0 ->
      IO.puts("#{x} is positive")
      x

    _ ->
      IO.puts("no match")
      x
  end

IO.puts("x is #{x}")

case 2 do
  ^x ->
    IO.puts("x is #{x}")

  _ ->
    IO.puts("no match")
end
