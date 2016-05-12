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
  return false if signal.length != unknowns.length

  actions = signal.map { |x| action(x) }
  return false if actions != actions.uniq

  signal.each_with_index do |move, i|
    sign = sign(move)
    other_player = other_player(move)
    unknown = unknowns[i]
    return false if sign != sign(unknown) || other_player != other_player(unknown)
  end

  return true
end

def valid_move?(branch, player, move)
  card = card(move)
  sign = sign(move)
  other_players = branch.keys.delete(player)

  return true if card == "??"

  if branch["discard"].include?(card)
    return false
  elsif sign == "+" && branch[player].include?(card)
    return false
  elsif sign == "-" && branch.values_at(*other_players).include?(card)
    return false
  end

  return true
end

def parse_signal_for_lil(signal, turn)
  unknowns = turn.moves.select { |x| x.include?("??") }
  new_moves = []
  count = 0
  turn.moves.each do |move|
    if unknowns.include?(move)
      new_moves.push(signal[count])
      count += 1
    else
      new_moves.push(move)
    end
  end

  turn = new_moves
end

def valid_turn?(turn)
  turn.moves.each do |moves|
    moves.each do |move|
      return false unless valid_move?(turn.player, move)
    end
  end

  return true
end

def modify_hand(branch, player, move)
  action = action(move)
  card = card(move)
  other_player = other_player(move)

  unless valid_move?(branch, player, move)
    puts player, move.inspect
    raise
  end

  if action.start_with? "+"
    branch[player].push(card)
  elsif action.start_with? "-"
    # todo - if player previously had only ??, but discards, then remove a ??
    branch[player].delete(card)
    branch["discard"].push(card) unless other_player
  end
end

def new_branch(old)
  Marshal.load(Marshal.dump(old))
end

@hands = {
  "Lil"     => [],
  "Shady"   => [],
  "Rocky"   => [],
  "Danny"   => [],
  "discard" => []
}

@signals = Hash.new { |h,k| h[k] = [] }
@rounds  = []


File.foreach("SAMPLE_INPUT.txt") do |turn|
  player = turn[/\A(\w+|\*) /, 1]
  moves  = turn.scan /[-+][0-9JQKA\?]{1,2}[CDHS\?]:*\w*/

  if player == "*"
    index = @rounds.length.pred
    @signals[index].push moves
  else
    turn = Turn.new(player, moves)

    if player == "Shady"
      @round   = Round.new
      @rounds << @round
    end

    @round << turn
  end
end

# round 0 is always valid
@rounds.first.turns.each do |turn|
  turn.moves.each do |move|
    modify_hand(@hands, turn.player, move)
  end
end

# Start the first branch from round 1
@rounds[1..-1].each do |round|
  old_branch = @branch ? @branch : @hands

  index = @rounds.index(round)
  puts "ROUND: #{index}"

  round.turns.each do |turn|
    if turn.player == "Lil"
      unknowns = turn.moves.select { |x| x.include?("??") }
      valid_signals = @signals[index].select { |x| valid_signal?(x, unknowns) }
      @branch = new_branch(old_branch) if valid_signals.length > 1

      # From here, move into possibilities
      @current_signal = valid_signals.first
      turn.moves = parse_signal_for_lil(@current_signal, turn)
    end

    turn.moves.each do |move|
      modify_hand(@hands, turn.player, move)
    end
  end
end
