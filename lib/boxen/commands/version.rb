require "boxen/commands"
require "boxen/commands/command"
require "boxen/version"

module Boxen
  module Commands
    class VersionCommand < Command
      def run
        puts "Boxen #{version}"
      end

      def version
        Boxen::VERSION
      end
    end
  end
end
