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
  "Lil"   => Player.new("Lil")
}

@signals = Hash.new { |h,k| h[k] = [] }

@rounds = []

@cards = []
@cards_in_play = []
@discarded = []
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

  if player == "*"
    index = @rounds.length.pred
    @signals[index].push moves
  else
    turn = Turn.new(@players[player], moves)

    if player == "Shady"
      @round   = Round.new
      @rounds << @round
    end

    @round << turn
  end
end


def parse_lil_turn(turn, round)
  signal = find_correct_signal(round)
  #puts signal.inspect

  #puts turn.moves.inspect

  new_moves = []
  count = 0
  turn.moves.each do |move|
    
    if move.include?("??")
      new_moves.push signal[count]
      count += 1
    else
      new_moves.push move
    end
  end

  new_moves
end

def correct_signal?(signal)
  signal.each do |move|
    action = move[/([-+][0-9JQKA?]{1,2}[CDHS?])/, 1]
    sign = action[0]
    card = action[1..-1]
    other_player = move[/:(Rocky|Danny|Shady)/, 1]

    if @discarded.include?(card)
      return false
    elsif sign == "+" && @players["Lil"].hand.include?(card)
      return false
    elsif sign == "+" && other_player && @players[other_player].hand.include?(card)
      return false
    end
  end

  return true
end

def find_correct_signal(round)
  @signals[round].select { |s| correct_signal?(s) }.flatten
end

@rounds.each_with_index do |round, i|
  round.turns.each do |turn|
    #puts turn.player.name
    #puts turn.moves.inspect

    if turn.player.name == "Lil" && i > 0
      #puts turn.moves.inspect
      turn.moves = parse_lil_turn(turn, i)
      #puts turn.moves.inspect
    end
    #puts turn.moves.inspect

    turn.moves.each do |move|
  
      #puts move.inspect
      action = move[/([-+][0-9JQKA?]{1,2}[CDHS?])/, 1]
      card = action[1..-1]
      other_player = move[/:(Rocky|Danny|Shady)/, 1]

      if action.start_with?  "+"
        turn.player.add card
      elsif action.start_with? "-"
        turn.player.remove card
        unless other_player
          @discarded.push(card)
          @cards_in_play.delete(card)
        end
      end
    end

    puts turn.player.hand.join(" ") if turn.player.name == "Lil"
  end
end
