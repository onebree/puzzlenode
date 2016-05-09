class Round
  def initialize
    @turns = []
  end
  
  def <<(turn)
    @turns << turn
  end
end

class Turn
  def initialize(player, move)
    @player = player
    @move = move
  end

  def moves
    draw = move[/(\+.{2,3}) /, 1]
    discard = move[/(-.{2,3}) /, 1]
    # receive
    # pass
  end
end




@rounds = []

File.foreach("INPUT.txt") do |turn|
  player = turn[/\A(\w+|\*) /, 1]
  move   = turn.scan /[+-][0-9JQKA?]{1,2}[CDHS?]/

  puts player, move.inspect, "\n"

  turn = Turn.new(player, move)

  if player == "Shady"
    @round   = Round.new
    @rounds << @round
  end

  @round  << turn
end

@cards = []

%w(2 3 4 5 6 7 8 9 10 A J Q K).each do |x|
  %w(C D S H).each do |s|
    @cards.push "#{x}#{s}"
  end
end

@cards_in_play = []
@discard = []
