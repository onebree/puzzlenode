def action(move)
  move[/([-+][0-9JQKA?]{1,2}[CDHS?])/]
end

def sign(move)
  action(move)[0]
end

def card(move)
  action(move)[1..-1]
end

def other_player(move)
  move[/:(Rocky|Danny|Shady)/, 1]
end

def valid_signal?(signal, unknowns)
  # If Lil has 3 unknowns, but the signal only fills in 2, then it must be false
  return false if signal.length != unknowns.length

  signal.each_with_index do |move, i|
    unknown = unknowns[i]

    action = action(move)
    sign = sign(move)
    card = card(move)
    other_player = other_player(move)

    # if playing a card that's already discarded
    if @discarded.include?(card)
      return false

    # if drawing a card that Lil already has
    # TODO - check DRAWING a card that other_player already has
    elsif action == "+" && @hands["Lil"].include?(card)
      return false

    # if passing a card that another player already has
    elsif action == "-" && @hands[other_player].include?(card)
      return false

    # ensures the order of signals match
    elsif sign != sign(unknown) || other_player != other_player(unknown)
      return false
    end
  end

  return true
end

@hands = {
  "Lil"   => %w( 5C 2H 8H 6D ),
  "Shady" => %w( QH AC 7C 2D 8C 3S ),
  "Rocky" => %w( KS ),
  "Danny" => %w( 4H ),
}

@discarded = %w( 4D 7D JS 6S 6H 2C 5D 3C )

signals = [
  ["+8H:Shady", "-2H:Danny", "+JD",  "+2D"],
  ["+8C:Shady", "-8C:Danny", "+JD",  "+4S"],
  ["+QH:Shady", "-2H:Danny", "+7D",  "+AS"],
  ["+AC:Shady", "-8H:Rocky", "+AS",  "+8D"],
  ["+8C:Shady", "-2H:Danny", "+10H", "+9H", "+4C"],
  ["-8H:Danny", "+8C:Shady", "+4S",  "+AS"],
]

turn = ["+??:Shady", "-6D:discard", "-??:Danny", "+??", "+??"]

unknowns = turn.select { |x| x.include?("??") }

branch = Marshal.load(Marshal.dump(@hands))

valid_signals = signals.select { |x| valid_signal?(x, unknowns) }
