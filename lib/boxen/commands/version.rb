require "boxen/commands"
require "boxen/commands/command"
require "boxen/version"

module Boxen
  module Commands
    class Version < Command
      def run
        puts "Boxen #{version}"
      end

      def version
        Boxen::VERSION
      end
    end
  end
end

Boxen::Commands.register :version, Boxen::Commands::Version
