tweets = File.readlines("sample_input.txt")

results = Hash.new { |h,k| h[k] = [] }

tweets.each do |tweet|
  owner    = tweet.scan(/\A(\w+):/).flatten[0]
  mentions = tweet.scan(/@(\w+)/).flatten
  results[owner] = results[owner] + mentions
end

results.each do |owner, mentions|
  results.each do |o, m|
    next if owner == o
    unless mentions.include?(o) && m.include?(owner)
      results[owner].delete(o)
    end
  end
end

connections = {}

results.each do |owner, mentions|
  connections[owner] = { first: mentions, second: [] }
  mentions.each do |mention|
    results[mention].each do |x|
      next if x == owner || mentions.include?(x)
      connections[owner][:second] << x
    end
  end

  connections[owner][:first].uniq!
  connections[owner][:second].uniq!
end

connections.each { |x,y| puts x, y, "\n" }
