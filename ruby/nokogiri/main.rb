require 'nokogiri'

if ARGV.empty?
  puts 'XML file is missing'
  exit 1
end

path = ARGV[0]

file = File.read(path)
doc = Nokogiri::XML(file)

orders = doc.xpath('//data/orders/*')
customers = doc.xpath('//data/customers/*')

active_count = 0
orders_per_customer = Hash.new(0)
items_per_customer = Hash.new(0)

orders.each do |order|
  customer_id = order['customer_id']
  status = order['status']
  active_count += 1 if status == 'active'

  orders_per_customer[customer_id] += 1

  items = order.xpath('items/*')
  items_per_customer[customer_id] += items.sum { |item| item['quantity'].to_i }
end

total_customers = orders_per_customer.keys.size
total_orders = orders_per_customer.values.sum
average_count = total_customers.zero? ? 0 : (total_orders.to_f / total_customers).round(2)

max_customer_id = items_per_customer.max_by { |_, v| v }&.first
customer_email = nil

customers.each do |customer|
  if customer['id'] == max_customer_id
    email_element = customer.at_xpath('email/*') || customer.at_xpath('email')
    customer_email = email_element&.text
    break
  end
end

puts "Active orders: #{active_count}"
puts "Average orders by customer: #{average_count}"
puts "Maximum items customer's email: #{customer_email}"
