require 'colorize'
require 'tty-table'
require 'pathname'

RESULTS_DIR = 'data/benchmark_results'

unless Dir.exist?(RESULTS_DIR)
  warn "❌ No benchmark results found in #{RESULTS_DIR}".red
  exit 1
end

results = []

Dir.glob("#{RESULTS_DIR}/**/*.log").each do |file|
  content = File.read(file)

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

min_real = results.map { _1[:real] }.min
min_mem  = results.map { _1[:mem]  }.min

rows = results.map do |r|
  real = (r[:real] == min_real ? format('%.2f', r[:real]).green : format('%.2f', r[:real]))
  mem  = (r[:mem]  == min_mem  ? r[:mem].to_s.green : r[:mem].to_s)

  [
    r[:lang].ljust(6),
    r[:impl],
    real,
    format('%.2f', r[:user]),
    format('%.2f', r[:sys]),
    mem
  ]
end

rows.sort_by! { |row| row[2].to_f }

table = TTY::Table.new(
  header: ['Lang', 'Implementation', 'Real (s)', 'User (s)', 'Sys (s)', 'Mem (KB)'],
  rows: rows
)

puts "\n📊 Benchmark Summary\n".bold
puts table.render(:unicode, padding: [0, 1, 0, 1])
