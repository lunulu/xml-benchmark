# frozen_string_literal: true

require 'ox'

if ARGV.empty?
  puts 'Нужен путь к XML-файлу'
  exit 1
end

path = ARGV[0]
count = 0

doc = Ox.load_file(path)

doc.locate('orders/*').each do |node|
  status = node[:status]
  count += 1 if status == 'active'
end

puts "Найдено active заказов: #{count}"
