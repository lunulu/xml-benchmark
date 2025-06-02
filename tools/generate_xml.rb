# frozen_string_literal: true

require 'ox'

def generate_large_xml(file_path, target_mb)
  target_bytes = target_mb * 1024 * 1024
  current_bytes = 0
  count = 0
  orders_count = 0
  customer_ids = []

  File.open(file_path, 'w') do |f|
    f.write(%(<?xml version="1.0" encoding="UTF-8"?>\n<data>\n<orders>\n))
    current_bytes += f.tell

    while current_bytes < target_bytes
      count += 1
      customer_id = 1000 + count
      customer_ids << customer_id

      rand(50).to_i.times do |i|
        orders_count += 1
        order = Ox::Element.new('order')
        order['id'] = (count + i).to_s
        order['customer_id'] = customer_id.to_s
        order['status'] = %w[active cancelled pending].sample

        items = Ox::Element.new('items')
        rand(1..3).to_i.times do |j|
          item = Ox::Element.new('item')
          item['id'] = "#{count}_#{j + 1}"
          item['quantity'] = rand(1..5).to_s

          name = Ox::Element.new('name')
          name << "Item #{j + 1}"
          price = Ox::Element.new('price')
          price << format('%.2f', rand * 100)

          item << name
          item << price
          items << item
        end

        order << items

        xml_string = Ox.dump(order)
        f.write(xml_string)
        current_bytes += xml_string.bytesize
      end
    end

    f.write(%(\n</orders>\n<customers>\n))

    customer_ids.each do |id|
      customer = Ox::Element.new('customer')
      customer['id'] = id.to_s

      name = Ox::Element.new('name')
      name << "Customer #{id}"
      email = Ox::Element.new('email')
      email << "customer#{id}@example.com"

      address = Ox::Element.new('address')
      street = Ox::Element.new('street')
      street << "Main St #{id}"
      city = Ox::Element.new('city')
      city << "City #{id % 100}"
      zip = Ox::Element.new('zip')
      zip << (10000 + id % 9000).to_s

      address << street
      address << city
      address << zip

      customer << name
      customer << email
      customer << address

      f.write(Ox.dump(customer))
    end

    f.write(%(\n</customers>\n</data>\n))
  end

  puts "✅ Сгенерирован файл: #{file_path} (примерно #{target_mb} МБ, #{orders_count} заказов)"
end

# ==== Параметры ====
file_path = ARGV[0] || 'input.xml'
size_mb = (ARGV[1] || 100).to_i

generate_large_xml(file_path, size_mb)
