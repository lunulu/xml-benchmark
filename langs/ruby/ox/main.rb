require 'ox'

if ARGV.empty?
  warn 'XML file is missing'
  exit 1
end

path = ARGV[0]
doc = Ox.load_file(path)

orders = doc.locate('data/orders/*')
customers_by_id = doc.locate('data/customers/*').to_h { |c| [c[:id], c] }

active_count = 0
orders_per_customer = Hash.new(0)
items_per_customer = Hash.new(0)

orders.each do |order|
  customer_id = order[:customer_id]
  orders_per_customer[customer_id] += 1

  if order[:status] == 'active'
    active_count += 1
  end

  item_count = 0
  if (items = order.locate('items/*')).any?
    item_count = items.sum { |item| item[:quantity].to_i }
  end
  items_per_customer[customer_id] += item_count
end

total_customers = orders_per_customer.size
total_orders = orders_per_customer.values.sum
average_count = total_customers.zero? ? 0 : (total_orders.to_f / total_customers).round(2)

max_customer_id = items_per_customer.max_by { |_, v| v }&.first
customer_email = if max_customer = customers_by_id[max_customer_id]
  max_customer.locate('email/*').first
end

puts "Active orders: #{active_count}"
puts "Average orders by customer: #{average_count}"
puts "Maximum items customer's email: #{customer_email}"
