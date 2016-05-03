require "json"
require "date"

SALES_TAX = 1.0411416

def to_float(input)
  input ? input[1..-1].to_f : 0.0
end

input = File.read("sample_input.txt")
vacation_rentals = JSON.parse File.read("sample_vacation_rentals.json")

start, finish = input.split(" - ").map { |x| Date.parse(x) }

vacation_rentals.each do |rental|
  name         = rental["name"]
  seasons      = rental["seasons"]
  rate         = rental["rate"]
  cleaning_fee = rental["cleaning fee"]

  next if rate.nil?

  subtotal = 
    if rate
      (start...finish).to_a.length * to_float(rate)
    else
      #
  end
  
  subtotal += to_float(cleaning_fee)

  total = subtotal * SALES_TAX
  total = total.round(2)

  puts "#{name}: $#{total}"
end
