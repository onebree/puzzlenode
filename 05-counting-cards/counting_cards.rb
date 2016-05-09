class Round
  attr_accessor :turns

  def initialize
    @turns = []
  end
  
  def <<(turn)
    @turns << turn
  end
end

class Turn
  attr_accessor :player, :moves

  def initialize(player, moves)
    @player = player
    @moves = moves
  end
end

class Player
  attr_accessor :name, :hand

  def initialize(name)
    @name  = name
    @hand  = []
  end

  def remove(card)
    @hand.delete card
  end

  def add(card)
    @hand.push card
  end
end

# Hash of all players (already known)
@players = {
  "Shady" => Player.new("Shady"),
  "Rocky" => Player.new("Rocky"),
  "Danny" => Player.new("Danny"),
  "Lil"   => Player.new("Lil"),
  "*"     => Player.new("*")
}

@rounds = []

@cards = []
@cards_in_play = []
@discard = []
@known = []

%w(2 3 4 5 6 7 8 9 10 A J Q K).each do |x|
  %w(C D S H).each do |s|
    card = "#{x}#{s}"
    @cards.push card
    @cards_in_play.push card
  end
end

File.foreach("SAMPLE_INPUT.txt") do |turn|
  player = turn[/\A(\w+|\*) /, 1]
  moves  = turn.scan /[-+][0-9JQKA\?]{1,2}[CDHS\?]:*\w*/

  turn = Turn.new(@players[player], moves)

  if player == "Shady"
    @round   = Round.new
    @rounds << @round
  elsif player == "*"
    # 2D array, where each 1D element is a round
    # Round 0 is dealing the cards, so an empty array is added instead
    signal = @players[player]
    signal.add([]) if signal.hand.empty?
    signal.add moves
  end

  @round << turn
end

def parse_lil_turn(turn, signals)
  new_moves = []
  count = 0
  turn.moves.each do |move|
    if move.include?("??")
      new_moves.push signals[count]
      count += 1
    else
      new_moves.push move
    end
  end

  new_moves
end

@rounds.each_with_index do |round, i|
  round.turns.each do |turn|
    if turn.player.name == "Lil" && i > 0
      turn.moves = parse_lil_turn(turn, @players["*"].hand[i])
    end

    turn.moves.each do |move|
      action = move[/([-+][0-9JQKA?]{1,2}[CDHS?])/, 1]
      card = action[1..-1]

      case move[/:(\w+)/, 1]
        when "discard", "*", nil
          other_player = nil
        else
          other_player = move[/:(\w+)/, 1]
      end

      if action.start_with?  "+"
        turn.player.add card
        @players[other_player].remove(card) if other_player && other_player != "discard"
      elsif action.start_with? "-"
        turn.player.remove card
        other_player ? @players[other_player].add(card) : @discard.push(card)
      end
    end

    if turn.player.name == "Lil"
      hand = turn.player.hand.select { |x| x != "??" }
      puts hand.join(" ")
    end
  end
end
