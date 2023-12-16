# Problem text: https://adventofcode.com/2023/day/7

defmodule AOC2023.CamelPokerPart2 do
  def solve do
    path = relative_from_here("input.txt")

    lines =
      read_file(path)

    do_solve(lines)
  end

  def do_solve(lines) do
    lines
    |> Enum.map(fn line ->
      %{hand: hand, bid: bid, hand_type: hand_type} = get_hand_and_bid_from_line(line)
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
    cards = hand_line |> String.split("", trim: true)

    # IO.puts("Processing line #{line}, cards #{inspect(cards, charlists: :as_lists)}, bid #{bid}")

    %{hand: hand, hand_type: hand_type} = get_hand_info_from_cards(cards)
    bid = bid |> String.to_integer()

    %{hand: hand, hand_type: hand_type, bid: bid}
  end

  def get_hand_info_from_cards(cards) do
    hand =
      extract_hand_from_cards(cards)

    hand_type = get_hand_type_from_hand(hand)

    %{hand: hand, hand_type: hand_type} =
      blend_jokers_in_hand(hand, hand_type)

    %{hand: hand, hand_type: hand_type}
  end

  @doc """
  Returns the hand as a list of lists, where each inner list contains the card and the number of times it occurs in the hand.
  The returned list is sorted by the rank of the cards.

  Example:
      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["2", "2", "3", "3", "3"])
      [[3, 3], [2, 2]]

      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["A", "A", "A", "A", "A"])
      [[:ace, 5]]

      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["J", "J", "J", "J", "J"])
      [[:joker, 5]]

      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["A", "A", "A", "A", "J"])
      [[:ace, 4], [:joker, 1]]

      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["T", "T", "T", "K", "J"])
      [[:king, 1], [:ten, 3], [:joker, 1]]

      iex> AOC2023.CamelPokerPart2.extract_hand_from_cards(["5", "J", "J", "3", "8"])
      [[8, 1], [5, 1], [3, 1], [:joker, 2]]
  """
  def extract_hand_from_cards(cards) do
    hand =
      cards
      |> Enum.map(fn card -> card_to_atom(card) end)
      # We use a list instead of a map because we want to preserve the order of the cards.
      |> Enum.reduce([], fn card, acc ->
        # IO.puts("Processing card #{card}, acc #{inspect(acc, charlists: :as_lists)}")
        found_card_idx = Enum.find_index(acc, fn [c, _count] -> c == card end)

        if found_card_idx do
          List.update_at(acc, found_card_idx, fn [c, count] -> [c, count + 1] end)
        else
          acc ++ [[card, 1]]
        end
      end)

    sorted_hand =
      hand
      |> Enum.sort(fn [card1, _count1], [card2, _count2] ->
        compare_cards_desc(card1, card2)
      end)

    # IO.puts("Sorted hand #{inspect(sorted_hand, charlists: :as_lists)}")

    sorted_hand
  end

  @doc """
  Given a hand and the hand type, applies the jokers s.t. the resulted hand it's the best possible hand for the given inputs.

  Returns the new hand and the new hand type.

  Examples:
      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[3, 4], [:joker, 1]], :four_of_a_kind)
      %{hand: [[3, 5]], hand_type: :five_of_a_kind}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[3, 3], [:joker, 2]], :three_of_a_kind)
      %{hand: [[3, 5]], hand_type: :five_of_a_kind}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[3, 3], [2, 1], [:joker, 1]], :three_of_a_kind)
      %{hand: [[3, 4], [2, 1]], hand_type: :four_of_a_kind}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[3, 2], [2, 2], [:joker, 1]], :two_pair)
      %{hand: [[3, 3], [2, 2]], hand_type: :full_house}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[3, 2], [2, 1], [:joker, 2]], :pair)
      %{hand: [[3, 4], [2, 1]], hand_type: :four_of_a_kind}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[:joker, 5]], :five_of_a_kind)
      %{hand: [[:joker, 5]], hand_type: :five_of_a_kind}

      iex> AOC2023.CamelPokerPart2.blend_jokers_in_hand([[:king, 5], [:joker, 0]], :five_of_a_kind)
      %{hand: [[:king, 5]], hand_type: :five_of_a_kind}
  """
  def blend_jokers_in_hand(hand, hand_type) do
    # IO.puts(
    #   "Blending jokers in hand #{inspect(hand, charlists: :as_lists)}, hand_type #{hand_type}"
    # )

    joker_card = hand |> Enum.find(fn [card, _count] -> card == :joker end)

    if joker_card == nil do
      %{hand: hand, hand_type: hand_type}
    else
      [_joker_sym, joker_count] = joker_card

      case joker_count do
        0 ->
          # Has zombie joker card
          clean_hand =
            hand
            |> Enum.filter(fn [card, _count] -> card != :joker end)

          %{hand: clean_hand, hand_type: hand_type}

        5 ->
          # Has 5 jokers
          %{hand: hand, hand_type: hand_type}

        _ ->
          hand =
            List.update_at(hand, -1, fn [card, count] -> [card, count - 1] end)

          # IO.puts("Hand after removing joker: #{inspect(hand, charlists: :as_lists)}")

          cond do
            hand_type == :four_of_a_kind ->
              four_of_a_kind_idx = Enum.find_index(hand, fn [_card, count] -> count == 4 end)

              new_hand =
                List.update_at(hand, four_of_a_kind_idx, fn [card, _count] -> [card, 5] end)

              blend_jokers_in_hand(new_hand, :five_of_a_kind)

            hand_type == :full_house or hand_type == :three_of_a_kind ->
              # Upgrade to four of a kind
              three_of_a_kind_idx = Enum.find_index(hand, fn [_card, count] -> count == 3 end)

              new_hand =
                List.update_at(hand, three_of_a_kind_idx, fn [card, _count] -> [card, 4] end)

              blend_jokers_in_hand(new_hand, :four_of_a_kind)

            hand_type == :two_pair ->
              # Upgrade to full house
              higher_pair_idx = Enum.find_index(hand, fn [_card, count] -> count == 2 end)

              new_hand = List.update_at(hand, higher_pair_idx, fn [card, _count] -> [card, 3] end)

              blend_jokers_in_hand(new_hand, :full_house)

            hand_type == :pair ->
              # Upgrade to three of a kind
              higher_pair_idx = Enum.find_index(hand, fn [_card, count] -> count == 2 end)

              # IO.puts("Hand with problem: #{inspect(hand, charlists: :as_lists)}")

              new_hand = List.update_at(hand, higher_pair_idx, fn [card, _count] -> [card, 3] end)

              blend_jokers_in_hand(new_hand, :three_of_a_kind)

            hand_type == :high_card ->
              # Upgrade to pair
              highest_card_idx = 0

              new_hand =
                List.update_at(hand, highest_card_idx, fn [card, _count] -> [card, 2] end)

              blend_jokers_in_hand(new_hand, :pair)

            true ->
              raise "Unexpected behaviour for hand #{inspect(hand, charlists: :as_lists)}, hand_type #{hand_type}"
          end
      end
    end
  end

  @doc """
  Returns the hand type of the given hand.

  Example:
      iex> AOC2023.CamelPokerPart2.get_hand_type_from_hand([[3, 2], [2, 3]])
      :full_house

      iex> AOC2023.CamelPokerPart2.get_hand_type_from_hand([[3, 2], [2, 1]])
      :pair

      iex> AOC2023.CamelPokerPart2.get_hand_type_from_hand([[8, 1], [5, 1], [3, 1], [:joker, 2]])
      :high_card

      iex> AOC2023.CamelPokerPart2.get_hand_type_from_hand([[:king, 1], [:joker, 4]])
      :high_card

      iex> AOC2023.CamelPokerPart2.get_hand_type_from_hand([[:joker, 5]])
      :five_of_a_kind
  """
  def get_hand_type_from_hand(hand) do
    joker_card = hand |> Enum.find(fn [card, _count] -> card == :joker end)

    case joker_card do
      [_c, 5] ->
        :five_of_a_kind

      _ ->
        hand = Enum.filter(hand, fn [card, _count] -> card != :joker end)

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
  end

  @doc """
  Returns {true, card} if the given hand is a full house, otherwise {false, nil}. The card is the card that is part of the three of a kind.

  Note: The hand is already sorted by the rank of the cards.

  Example:

      iex> AOC2023.CamelPokerPart2.is_full_house?([[3, 2], [2, 3]])
      true

      iex> AOC2023.CamelPokerPart2.is_full_house?([[3, 2], [2, 1]])
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

      iex> AOC2023.CamelPokerPart2.is_two_pair?([[3, 2], [2, 2]])
      {true, 3}

      iex> AOC2023.CamelPokerPart2.is_two_pair?([[3, 2], [2, 1]])
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

      iex> AOC2023.CamelPokerPart2.is_n_of_a_kind?([[3, 2], [2, 3]], 2)
      {true, 3}

      iex> AOC2023.CamelPokerPart2.is_n_of_a_kind?([[3, 2], [2, 1]], 3)
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

    is_same_hand_type? = hand_type_value_1 == hand_type_value_2

    if is_same_hand_type? do
      card_pairs =
        Enum.zip(
          String.split(hand_str_1, "", trim: true),
          String.split(hand_str_2, "", trim: true)
        )

      card_pairs
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

      iex> AOC2023.CamelPokerPart2.compare_cards_desc(:ten, :ace)
      false

      iex> AOC2023.CamelPokerPart2.compare_cards_desc(:ace, :ten)
      true
  """
  def compare_cards_desc(card_sym_1, card_sym_2) do
    card1_int = card_atom_to_int(card_sym_1)
    card2_int = card_atom_to_int(card_sym_2)

    card1_int >= card2_int
  end

  def card_to_atom(card) do
    case card do
      "J" -> :joker
      "T" -> :ten
      "Q" -> :queen
      "K" -> :king
      "A" -> :ace
      _ -> card |> String.to_integer()
    end
  end

  @doc """
  Converts the given card to an integer.

  Example:

      iex> AOC2023.CamelPokerPart2.card_atom_to_int(:ten)
      10

      iex> AOC2023.CamelPokerPart2.card_atom_to_int(:ace)
      14

      iex> AOC2023.CamelPokerPart2.card_atom_to_int(:joker)
      1

      iex> AOC2023.CamelPokerPart2.card_atom_to_int(2)
      2
  """
  def card_atom_to_int(card) do
    case card do
      :joker -> 1
      :ten -> 10
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
    # IO.puts("[read_file] Reading from #{path}")

    case File.read(path) do
      {:ok, content} ->
        # IO.puts("[read_file] Read #{content |> String.length()} bytes")
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
