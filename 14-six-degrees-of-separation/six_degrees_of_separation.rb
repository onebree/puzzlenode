@results = Hash.new { |h,k| h[k] = [] }

File.foreach("complex_input.txt") do |tweet|
  owner    = tweet[/\A(\w+):/, 1]
  mentions = tweet.scan(/@(\w+)/).flatten

  @results[owner] = @results[owner] + mentions
end

@results.each do |owner, mentions|
  @results.keys.each do |o|
    next if o == owner
    next if mentions.include?(o) && @results[o].include?(owner)
    mentions.delete(o)
  end

  mentions.uniq!
  m = mentions.dup
  m.each do |x|
    mentions.delete(x) unless @results.keys.include?(x)
  end
end

@connections = {}

@results.each { |o,m| @connections[o] = { "0" => m.sort } }

(1..@results.length).each do |degree|
  @results.each do |owner, mentions|
    @connections[owner][degree.to_s] = []

    @connections[owner][degree.pred.to_s].each do |mention|
      next unless @results.keys.include?(mention)
      @results[mention].each do |m|
        next if owner == m
        @connections[owner][degree.to_s] << m
      end
    end

    @connections[owner][degree.to_s].uniq!

    degree.pred.downto(0) do |n|
      @connections[owner][degree.to_s] = @connections[owner][degree.to_s] - @connections[owner][n.to_s]
    end
  end
end

output = File.open("output.txt", "w")
@connections.sort.each do |owner, degrees|
  output.puts owner
  degrees.each do |deg, mentions|
    next if mentions.empty?
    output.puts mentions.sort.join(", ")
  end
  output.puts "\n" unless @connections.keys.sort.last == owner
end
