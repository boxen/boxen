require "json"

dot_boxen = "#{ENV['HOME']}/.boxen"

if File.exist? dot_boxen
  facts = JSON.parse(File.read(dot_boxen))
  facts.each { |k, v| Facter.add(k) { setcode { v } } }
end
