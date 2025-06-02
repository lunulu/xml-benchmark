require 'rexml/document'
require 'pry'

if ARGV.empty?
  puts 'XML file is missing'
  exit 1
end

path = ARGV[0]

file = File.read(path)
doc = REXML::Document.new(file)

orders = REXML::XPath.match(doc, 'data/orders/order')
customers = REXML::XPath.match(doc, 'data/customers/customer')

active_count = 0
orders_per_customer = Hash.new(0)
items_per_customer = Hash.new(0)

orders.each do |order|
  customer_id = order.attributes['customer_id']
  status = order.attributes['status']
  active_count += 1 if status == 'active'

  orders_per_customer[customer_id] += 1

  items = REXML::XPath.match(order, 'items/item')
  items_per_customer[customer_id] += items.size
end

total_customers = orders_per_customer.keys.size
total_orders = orders_per_customer.values.sum
average_count = total_customers.zero? ? 0 : (total_orders.to_f / total_customers).round(2)

max_customer_id = items_per_customer.max_by { |_, v| v }&.first
customer_email = nil

customers.each do |customer|
  if customer.attributes['id'] == max_customer_id
    email_element = REXML::XPath.first(customer, 'email')
    customer_email = email_element&.text
    break
  end
end

puts "Active orders: #{active_count}"
puts "Average orders by customer: #{average_count}"
puts "Maximum items customer's email: #{customer_email}"
