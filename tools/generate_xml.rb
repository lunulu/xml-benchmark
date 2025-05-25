# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
def generate_large_xml(file_path, target_mb)
  target_bytes = target_mb * 1024 * 1024
  count = 0

  File.open(file_path, 'w') do |f|
    f.puts '<?xml version="1.0" encoding="UTF-8"?>'
    f.puts '<orders>'

    while f.tell < target_bytes
      count += 1
      f.puts "  <order id=\"#{count}\" status=\"#{%w[active cancelled pending].sample}\">"
      f.puts "    <customer>Customer #{count}</customer>"
      f.puts '  </order>'
    end

    f.puts '</orders>'
  end

  puts "✅ Сгенерирован файл: #{file_path} (примерно #{target_mb} МБ, #{count} заказов)"
end
# rubocop:enable Metrics/MethodLength

# ==== Параметры ====
file_path = ARGV[0] || 'output.xml'
size_mb   = (ARGV[1] || 100).to_i # по умолчанию 100 МБ

generate_large_xml(file_path, size_mb)
