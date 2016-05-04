tweets = File.readlines("sample_input.txt")

@results = Hash.new { |h,k| h[k] = [] }

tweets.each do |tweet|
  owner    = tweet.scan(/\A(\w+):/).flatten[0]
  mentions = tweet.scan(/@(\w+)/).flatten
  @results[owner] = @results[owner] + mentions
end

@results.each do |owner, mentions|
  @results.each do |o, m|
    next if owner == o
    unless mentions.include?(o) && m.include?(owner)
      @results[owner].delete(o)
    end
  end
end

@connections = {}

@results.each { |o,m| @connections[o] = { "0" => m.sort } }

(1..@results.length).each do |degree|
  @results.each do |owner, mentions|
    @connections[owner][degree.to_s] = []

    @connections[owner][degree.pred.to_s].each do |mention|
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

@connections.sort.each do |owner, degrees|
  puts owner
  degrees.each do |deg, mentions|
    next if mentions.empty?
    puts mentions.sort.join(", ")
  end
  puts "\n"
end
