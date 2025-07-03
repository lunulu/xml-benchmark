require 'colorize'
require 'tty-table'
require 'pathname'
require 'fileutils'
require 'optparse'

RESULTS_DIR = 'data/benchmark_results'
OUTPUT_MD   = 'docs/benchmark_table.md'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb [options]"
  opts.on('-u', '--update-md', 'Update benchmark_table.md') do
    options[:update_md] = true
  end
end.parse!

unless Dir.exist?(RESULTS_DIR)
  warn "❌ No benchmark results found in #{RESULTS_DIR}".red
  exit 1
end

results = []
reference_lines = nil
inconsistent_files = []

Dir.glob("#{RESULTS_DIR}/**/*.log").each do |file|
  content = File.read(file)
  lines = content.lines.map(&:strip)

  next if lines.size < 3

  current_lines = lines[0..2]
  if reference_lines.nil?
    reference_lines = current_lines
  elsif reference_lines != current_lines
    inconsistent_files << file
    warn "⚠️  Skipping inconsistent benchmark output: #{file}".yellow
    next
  end

  variant_path = Pathname(file).relative_path_from(Pathname(RESULTS_DIR)).to_s
  lang, impl = variant_path.sub('.log', '').split('/')

  real = content[/real:\s*([\d.]+)/, 1]&.to_f
  user = content[/user:\s*([\d.]+)/, 1]&.to_f
  sys  = content[/sys:\s*([\d.]+)/, 1]&.to_f
  mem  = content[/mem:\s*(\d+)/, 1]&.to_i

  if [real, user, sys, mem].any?(&:nil?)
    warn "⚠️  Skipping incomplete log: #{file}".yellow
    next
  end

  results << {
    lang: lang,
    impl: impl,
    real: real,
    user: user,
    sys: sys,
    mem: mem
  }
end

if results.empty?
  warn "❌ No valid benchmark logs found.".red
  exit 1
end

puts "\n🔍 Checking benchmark consistency...\n\n"
puts "Reference output (first 3 lines):".light_blue
puts reference_lines.map { |line| "  #{line}" }.join("\n")
puts

puts "✅ All benchmark outputs are valid.\n".green if inconsistent_files.empty?

min_real = results.map { _1[:real] }.min
min_mem  = results.map { _1[:mem]  }.min

rows = results.map do |r|
  real_colored = (r[:real] == min_real ? format('%.2f', r[:real]).green : format('%.2f', r[:real]))
  mem_colored  = (r[:mem]  == min_mem  ? r[:mem].to_s.green : r[:mem].to_s)

  [
    r[:lang].ljust(6),
    r[:impl],
    real_colored,
    format('%.2f', r[:user]),
    format('%.2f', r[:sys]),
    mem_colored
  ]
end

rows.sort_by! { |row| row[2].to_f }

puts "\n📊 Benchmark Summary\n".bold
tty_table = TTY::Table.new(
  header: ['Lang', 'Implementation', 'Real (s)', 'User (s)', 'Sys (s)', 'Mem (KB)'],
  rows: rows
)
puts tty_table.render(:unicode, padding: [0, 1, 0, 1])

if options[:update_md]
  markdown_rows = results.sort_by { _1[:real] }.map do |r|
    real = (r[:real] == min_real ? "**#{format('%.2f', r[:real])}**" : format('%.2f', r[:real]))
    mem  = (r[:mem]  == min_mem  ? "**#{r[:mem]}**" : r[:mem].to_s)

    "| #{r[:lang].ljust(6)} | #{r[:impl]} | #{real} | #{format('%.2f', r[:user])} | #{format('%.2f', r[:sys])} | #{mem} |"
  end

  markdown_output = <<~MD
    ## 📄 Full Benchmark Table

    | Lang   | Implementation    | Real (s) | User (s) | Sys (s) | Mem (KB) |
    |--------|-------------------|----------|----------|---------|----------|
    #{markdown_rows.join("\n")}
  MD

  FileUtils.mkdir_p(File.dirname(OUTPUT_MD))
  File.write(OUTPUT_MD, markdown_output)
  puts "\n✅ Markdown table written to #{OUTPUT_MD}\n".green
end
