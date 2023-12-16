defmodule AOC2023.CamelPoker do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    lines
    |> Enum.map(fn line ->
      {hand, bid} = get_hand_and_bid_from_line(line)
      hand_type = get_hand_type_from_hand(hand)

      %{hand: hand, bid: bid, hand_type: hand_type, hand_str: line}
    end)
    |> Enum.sort(fn %{hand_type: hand_type_1, hand_str: hand_str_1},
                    %{hand_type: hand_type_2, hand_str: hand_str_2} ->
      compare_hand_types_asc(
        %{hand_type: hand_type_1, hand_str: hand_str_1},
        %{hand_type: hand_type_2, hand_str: hand_str_2}
      )
    end)
    |> compute_winnings()
  end

  def compute_winnings(hands) do
    hands
    |> Enum.with_index()
    |> Enum.reduce(0, fn {%{bid: bid}, idx}, acc ->
      acc + bid * (idx + 1)
    end)
  end

  def get_hand_and_bid_from_line(line) do
    [hand_line, bid] = String.split(line, " ", trim: true)

    hand = extract_hand_from_hand_line(hand_line)
    bid = bid |> String.to_integer()

    {hand, bid}
  end

  def extract_hand_from_hand_line(hand_line) do
    cards = hand_line |> String.split("", trim: true)
    result = get_hand_from_cards(cards)

    result
  end

  @doc """
  Returns the hand as a list of lists, where each inner list contains the card and the number of times it occurs in the hand.

  Example:
      iex> AOC2023.CamelPoker.get_hand_from_cards(["2", "2", "3", "3", "3"])
      [[3, 3], [2, 2]]

      iex> AOC2023.CamelPoker.get_hand_from_cards(["A", "A", "A", "A", "A"])
      [[:ace, 5]]
  """
  def get_hand_from_cards(cards) do
    cards
    |> Enum.map(fn card -> card_to_atom(card) end)
    # We use a list instead of a map because we want to preserve the order of the cards.
    |> Enum.reduce([], fn card, acc ->
      found_card_idx = Enum.find_index(acc, fn [c, _count] -> c == card end)

      if found_card_idx do
        List.update_at(acc, found_card_idx, fn [card, count] -> [card, count + 1] end)
      else
        acc ++ [[card, 1]]
      end
    end)
    |> Enum.sort(fn [card1, _count1], [card2, _count2] ->
      compare_cards_desc(card1, card2)
    end)
  end

  @doc """
  Returns the hand type of the given hand.

  Example:
      iex> AOC2023.CamelPoker.get_hand_type_from_hand([[3, 2], [2, 3]])
      :full_house

      iex> AOC2023.CamelPoker.get_hand_type_from_hand([[3, 2], [2, 1]])
      :pair
  """
  def get_hand_type_from_hand(hand) do
    {is_five_of_a_kind, _card} = is_n_of_a_kind?(hand, 5)

    if is_five_of_a_kind do
      :five_of_a_kind
    else
      {is_four_of_a_kind, _card} = is_n_of_a_kind?(hand, 4)

      if is_four_of_a_kind do
        :four_of_a_kind
      else
        is_full_house = is_full_house?(hand)

        if is_full_house do
          :full_house
        else
          {is_three_of_a_kind, _card} = is_n_of_a_kind?(hand, 3)

          if is_three_of_a_kind do
            :three_of_a_kind
          else
            {is_two_pair, _card} = is_two_pair?(hand)

            if is_two_pair do
              :two_pair
            else
              {is_pair, _card} = is_n_of_a_kind?(hand, 2)

              if is_pair do
                :pair
              else
                :high_card
              end
            end
          end
        end
      end
    end
  end

  @doc """
  Returns {true, card} if the given hand is a full house, otherwise {false, nil}. The card is the card that is part of the three of a kind.

  Note: The hand is already sorted by the rank of the cards.

  Example:

      iex> AOC2023.CamelPoker.is_full_house?([[3, 2], [2, 3]])
      true

      iex> AOC2023.CamelPoker.is_full_house?([[3, 2], [2, 1]])
      false
  """
  def is_full_house?(hand) do
    {is_three_of_a_kind, card} = is_n_of_a_kind?(hand, 3)

    if not is_three_of_a_kind do
      false
    else
      new_hand = remove_card_from_hand(hand, card)
      {is_pair, _card} = is_n_of_a_kind?(new_hand, 2)

      if is_pair do
        true
      else
        false
      end
    end
  end

  @doc """
  Returns {true, card} if the given hand is a two pair, otherwise {false, nil}. The card is the card from the higher pair.

  Example:

      iex> AOC2023.CamelPoker.is_two_pair?([[3, 2], [2, 2]])
      {true, 3}

      iex> AOC2023.CamelPoker.is_two_pair?([[3, 2], [2, 1]])
      {false, nil}
  """
  def is_two_pair?(hand) do
    {is_pair, card} = is_n_of_a_kind?(hand, 2)

    if not is_pair do
      {false, nil}
    else
      new_hand = remove_card_from_hand(hand, card)
      {is_pair, _card} = is_n_of_a_kind?(new_hand, 2)

      if is_pair do
        {true, card}
      else
        {false, nil}
      end
    end
  end

  @doc """
  Returns {true, card} if the given hand is a n-of-a-kind, otherwise {false, nil}. The card is the card that is part of the n-of-a-kind.

  Note: The hand is already sorted by the rank of the cards.

  Example:

      iex> AOC2023.CamelPoker.is_n_of_a_kind?([[3, 2], [2, 3]], 2)
      {true, 3}

      iex> AOC2023.CamelPoker.is_n_of_a_kind?([[3, 2], [2, 1]], 3)
      {false, nil}
  """
  def is_n_of_a_kind?(hand, n) do
    found_card =
      hand
      |> Enum.find(fn [_card, count] ->
        count == n
      end)

    if found_card do
      {true, Enum.at(found_card, 0)}
    else
      {false, nil}
    end
  end

  def compare_hand_types_asc(
        %{hand_type: hand_type_atom_1, hand_str: hand_str_1},
        %{hand_type: hand_type_atom_2, hand_str: hand_str_2}
      ) do
    hand_type_value_1 = get_hand_type_value(hand_type_atom_1)
    hand_type_value_2 = get_hand_type_value(hand_type_atom_2)

    if hand_type_value_1 == hand_type_value_2 do
      Enum.zip(String.split(hand_str_1, "", trim: true), String.split(hand_str_2, "", trim: true))
      |> Enum.reduce_while(nil, fn {card_str_1, card_str_2}, _ ->
        card_1 = card_to_atom(card_str_1)
        card_2 = card_to_atom(card_str_2)

        if card_1 == card_2 do
          {:cont, nil}
        else
          if compare_cards_desc(card_1, card_2) do
            {:halt, false}
          else
            {:halt, true}
          end
        end
      end)
    else
      hand_type_value_1 < hand_type_value_2
    end
  end

  def get_hand_type_value(hand_type) do
    case hand_type do
      :five_of_a_kind -> 7
      :four_of_a_kind -> 6
      :full_house -> 5
      :three_of_a_kind -> 4
      :two_pair -> 3
      :pair -> 2
      :high_card -> 1
    end
  end

  @doc """
  Used when creating the hand from the cards. Compares the given cards in descending order. It is helpful when determining the hand type.

  Returns true card 1 should be before card 2, otherwise false.

  Example:

      iex> AOC2023.CamelPoker.compare_cards_desc(:ten, :ace)
      false

      iex> AOC2023.CamelPoker.compare_cards_desc(:ace, :ten)
      true
  """
  def compare_cards_desc(card_sym_1, card_sym_2) do
    card1_int = card_atom_to_int(card_sym_1)
    card2_int = card_atom_to_int(card_sym_2)

    card1_int >= card2_int
  end

  def card_to_atom(card) do
    case card do
      "T" -> :ten
      "J" -> :jack
      "Q" -> :queen
      "K" -> :king
      "A" -> :ace
      _ -> card |> String.to_integer()
    end
  end

  @doc """
  Converts the given card to an integer.

  Example:

      iex> AOC2023.CamelPoker.card_atom_to_int(:ten)
      10

      iex> AOC2023.CamelPoker.card_atom_to_int(:ace)
      14

      iex> AOC2023.CamelPoker.card_atom_to_int(2)
      2
  """
  def card_atom_to_int(card) do
    case card do
      :ten -> 10
      :jack -> 11
      :queen -> 12
      :king -> 13
      :ace -> 14
      _ -> card
    end
  end

  def remove_card_from_hand(hand, card) do
    card_to_remove_idx = Enum.find_index(hand, fn [c, _count] -> c == card end)

    if card_to_remove_idx == nil do
      raise "Could not find card #{card} in hand #{hand}"
    else
      List.delete_at(hand, card_to_remove_idx)
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
