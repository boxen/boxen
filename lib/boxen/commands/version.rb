require "boxen/commands"
require "boxen/commands/command"
require "boxen/version"

module Boxen
  module Commands
    class Version < Command
      def self.help
        "Displays the current version of Boxen"
      end

      def run
        puts "Boxen #{version}"
        Status.new(0)
      end

      def version
        Boxen::VERSION
      end
    end
  end
end

Boxen::Commands.register :version, Boxen::Commands::Version
