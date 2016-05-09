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

  # WIP method
  # Pushes card values from that turn to the appropriate arrays
  # discard pile, drawn cards, passed cards, received cards
  def cards
    draw, receive, discard, pass = [] * 4

    moves.each do |card|
      value = card[/[0-9JQKA?]{1,2}[CDHS?]/]
      next if value == "??"
      case card
        when /\+.{2,3}:\w+/
          receive << value
        when /\+.{2,3}/
          draw << value
        when /-.{2,3}:\w+/
          pass << value
        when /-.{2,3}/
          discard << value
      end
    end
    
    [draw, receive, discard, pass]
  end
end

class Player
  attr_accessor :name, :hand

  def initialize(name)
    @name = name
    @hand = []
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

File.foreach("INPUT.txt") do |turn|
  player = turn[/\A(\w+|\*) /, 1]
  moves  = turn.scan /[+-][0-9JQKA?]{1,2}[CDHS?]/

  turn = Turn.new(@players[player], moves)

  if player == "Shady"
    @round   = Round.new
    @rounds << @round
  end

  @round  << turn
end


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


# Calculate the hand of each player by turn's end
# Still need to account for the results of a true signal
# Also, if player discards, remove such card (or ??) from hand
def calculate_hand(player, move)
  action = move[/([-+][0-9JQKA?]{1,2}[CDHS?])/, 1]
  card = action[1..-1]
  other_player = move[/:(\w+)/, 1]

  if action.start_with?  "+"
    player.add card
    other_player ? other_player.remove(card) : @cards_in_play.push(card)
  elsif card.end_with? "-"
    player.remove card
    other_player ? other_player.add(card) : @discard.push(card)
  end
end


# Calculate whether hints are false, or true (then proceeed)
# FALSE 
#   if +card inside discard pile
#   if -card in discard pile BEFORE Lil's turn
#   if Rocky has +card
#   if Rocky has -card:other
def calculate_hints(move)
  action = move[/([-+][0-9JQKA?]{1,2}[CDHS?])/, 1]
  card = action[1..-1]
  other_player = move[/:(\w+)/, 1]
end


@rounds.each do |round|
  round.turns.each do |turn|
    player = turn.player
    moves = turn.moves
    
    # Check output of first round
    raise if player.name == "*"

    moves.each do |move|
      calculate_hand(player, move)
    end
    puts player.name, player.hand.inspect, "\n"
  end
end
