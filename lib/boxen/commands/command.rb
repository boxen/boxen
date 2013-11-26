require "boxen/commands"

module Boxen
  module Commands
    class Command
      def run
        raise NotImplementedError
      end
    end
  end
end
