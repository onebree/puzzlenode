require "json"
require "date"

SALES_TAX = 1.0411416

def to_f(input)
  input[1..-1].to_f
end

def to_date(date, year)
  month, day = date.split("-").map(&:to_i)
  Date.new(year, month, day)
end

def seasons_hash(seasons)
  seasons_new = {}
  seasons.each { |season| seasons_new.merge!(season) }
  seasons_new.each do |_, season|
    season_start = to_date(season["start"], @start.year)
    season["range"] =
      if season["start"]  < season["end"]
        (season_start..to_date(season["end"], @start.year))
      else
        (season_start..to_date(season["end"], @start.year.next))
    end
  end
  seasons_new
end

input  = File.read("input.txt")
output = File.open("output.txt", "w")
vacation_rentals = JSON.parse File.read("vacation_rentals.json")

@start, @finish = input.split(" - ").map { |day| Date.parse(day) }

vacation_rentals.each do |rental|
  name         = rental["name"]
  seasons      = rental["seasons"]
  rate         = rental["rate"]
  cleaning_fee = rental["cleaning fee"]

  subtotal = 
    if rate
      (@start...@finish).to_a.length * to_f(rate)
    else
      seasons = seasons_hash(seasons)
      season_rate = 0.0
      (@start...@finish).each do |day|
        seasons.each do |_, values|
          season_rate += to_f(values["rate"]) if values["range"].include?(day)
        end
      end
      season_rate
  end
  
  subtotal += to_f(cleaning_fee) if cleaning_fee
  total = subtotal * SALES_TAX
  total = "%.02f" % total

  output.puts "#{name}: $#{total}"
end
