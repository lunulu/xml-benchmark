require 'ox'

if ARGV.empty?
  puts 'XML file is missing'
  exit 1
end

path = ARGV[0]

class OrderStatsHandler < ::Ox::Sax
  attr_reader :active_count, :orders_per_customer, :items_per_customer, :customers

  def initialize
    @active_count = 0
    @orders_per_customer = Hash.new(0)
    @items_per_customer = Hash.new(0)
    @customers = {}

    @in_order = false
    @in_items = false
    @in_customer = false
    @in_email = false

    @current_customer_id = nil
    @current_order_status = nil
    @items_count = 0
    @current_customer_id_for_email = nil
    @current_email = nil
  end

  def start_element(name)
    case name
    when :order
      @in_order = true
      @current_customer_id = nil
      @current_order_status = nil
      @items_count = 0
    when :items
      @in_items = true if @in_order
    when :item
      @items_count += 1 if @in_items
    when :customer
      @in_customer = true
      @current_email = nil
    when :email
      @in_email = true if @in_customer
    end
  end

  def end_element(name)
    case name
    when :order
      if @current_customer_id
        @orders_per_customer[@current_customer_id] += 1
        @items_per_customer[@current_customer_id] += @items_count
        @active_count += 1 if @current_order_status == 'active'
      end
      @in_order = false
    when :items
      @in_items = false
    when :customer
      if @current_customer_id_for_email && @current_email
        @customers[@current_customer_id_for_email] = @current_email
      end
      @in_customer = false
      @current_customer_id_for_email = nil
    when :email
      @in_email = false
    end
  end

  def attr(name, value)
    if @in_order
      case name
      when :customer_id
        @current_customer_id = value
      when :status
        @current_order_status = value
      end
    elsif @in_customer && name == :id
      @current_customer_id_for_email = value
    end
  end

  def text(value)
    if @in_customer && @in_email
      @current_email = value.strip
    end
  end
end

handler = OrderStatsHandler.new
Ox.sax_parse(handler, File.open(path, 'r:utf-8'))

orders_per_customer = handler.orders_per_customer
items_per_customer = handler.items_per_customer

total_customers = orders_per_customer.keys.size
total_orders = orders_per_customer.values.sum
average_count = total_customers.zero? ? 0 : (total_orders.to_f / total_customers).round(2)

max_customer_id = items_per_customer.max_by { |_, v| v }&.first
customer_email = handler.customers[max_customer_id]

puts "Active orders: #{handler.active_count}"
puts "Average orders by customer: #{average_count}"
puts "Maximum items customer's email: #{customer_email}"
