require 'nokogiri'

if ARGV.empty?
  warn 'XML file is missing'
  exit 1
end

path = ARGV[0]
doc = Nokogiri::XML(File.read(path))

orders = doc.xpath('//data/orders/*')
customers_by_id = doc.xpath('//data/customers/*').to_h { |c| [c['id'], c] }

active_count = 0
orders_per_customer = Hash.new(0)
items_per_customer = Hash.new(0)

orders.each do |order|
  customer_id = order['customer_id']
  orders_per_customer[customer_id] += 1
  active_count += 1 if order['status'] == 'active'

  items = order.xpath('items/*[@quantity]')
  item_count = items.sum { |item| item['quantity'].to_i }
  items_per_customer[customer_id] += item_count
end

total_customers = orders_per_customer.size
total_orders = orders_per_customer.values.sum
average_count = total_customers.zero? ? 0 : (total_orders.to_f / total_customers).round(2)

max_customer_id = items_per_customer.max_by { |_, count| count }&.first
customer_node = customers_by_id[max_customer_id]
customer_email = customer_node&.at_xpath('email')&.text

puts "Active orders: #{active_count}"
puts "Average orders by customer: #{average_count}"
puts "Maximum items customer's email: #{customer_email}"
