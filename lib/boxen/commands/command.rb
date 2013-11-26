require "boxen/commands"

module Boxen
  module Commands
    class Command

      class << self
        def preflight(*klasses)
          if defined?(@preflight)
            @preflight += klasses
          else
            @preflight = klasses
          end
        end

        def postflight(*klasses)
          if defined?(@postflight)
            @postflight += klasses
          else
            @postflight = klasses
          end
        end
      end

      def initialize(*args)
        @args = args
      end

      def invoke
        if self.class.preflight.all? { |p| p = p.new; p.run unless p.ok? }
          self.run
          self.class.postflight.each { |p| p = p.new; p.run unless p.ok? }
        end
      end

      def run
        raise NotImplementedError
      end
    end
  end
end
