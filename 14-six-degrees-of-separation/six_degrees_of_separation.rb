tweets = File.readlines("sample_input.txt")

results = Hash.new( [] )

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

puts results.inspect

