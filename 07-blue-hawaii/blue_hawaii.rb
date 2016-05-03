require "json"
require "date"

SALES_TAX = 1.0411416

def to_float(input)
  input ? input[1..-1].to_f : 0.0
end

def seasons_hash(seasons)
  seasons_new = {
    winter: seasons[0]["one"],
    summer: seasons[1]["two"]
  }

  seasons_new[:winter]["rate"] = to_float(seasons_new[:winter]["rate"])
  seasons_new[:summer]["rate"] = to_float(seasons_new[:summer]["rate"])
  seasons_new
end

input = File.read("sample_input.txt")
vacation_rentals = JSON.parse File.read("sample_vacation_rentals.json")
output = File.open("sample_output.txt", "w")

start, finish = input.split(" - ").map { |x| Date.parse(x) }

vacation_rentals.each do |rental|
  name         = rental["name"]
  seasons      = rental["seasons"]
  rate         = rental["rate"]
  cleaning_fee = rental["cleaning fee"]

  subtotal = 
    if rate
      (start...finish).to_a.length * to_float(rate)
    else
      seasons = seasons_hash(seasons)
      winter = (seasons[:winter]["start"]..seasons[:winter]["end"])
      summer = (seasons[:summer]["start"]..seasons[:summer]["end"])
      
      season_rate = 0.0

      (start...finish).each do |day|
        if winter.include? day.strftime("%m-%d")
          season_rate += seasons[:winter]["rate"]
        else
          season_rate += seasons[:summer]["rate"]
        end
      end
      season_rate
  end
  
  subtotal += to_float(cleaning_fee)

  total = subtotal * SALES_TAX
  total = total.round(2)

  output.puts "#{name}: $#{total}"
end
