require "boxen/check"

module Boxen
  class Preflight < Boxen::Check
  end
end

Dir["#{File.expand_path('../preflight', __FILE__)}/*"].each do |f|
  require "boxen/preflight/#{File.basename f}"
end
