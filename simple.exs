IO.puts("hello" <> " world")

list = [1, 2, 3]

list = list ++ [4, 5, 6]
IO.inspect(list)

list = list -- [4, 5, 6]
IO.inspect(list)

IO.puts("head of list: #{hd(list)}")
IO.inspect("tail of list: #{tl(list)}")

i(~c"hello")

# length means it's computed, mnemonic: "l" is for "linear"
# size means it's pre-computed, mnemonic: "s" is for "static"

### PATTERN MATCHING ###

# a=:hello, b="world", c=42
{a, b, c} = {:hello, "world", 42}

# a=:hello, b="world", c=42
[a, b, c] = [:hello, "world", 42]

# this will match only if the first element of RHS is :ok
{:ok, result} = {:ok, 13}

# head = 1, tail = [2, 3]
[head | tail] = [1, 2, 3]
