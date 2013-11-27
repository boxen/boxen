require "boxen/commands"
require "boxen/config"
require "boxen/flags"

module Boxen
  module Commands
    class Command

      class Status < Struct.new(:code)
        def success?
          if defined?(@successful)
            @successful.include?(code)
          else
            0 == code
          end
        end

        def successful_on(*args)
          @successful = args
        end
      end

      attr_reader :config, :flags

      def self.preflight(*klasses)
        preflights.replace preflights | klasses.flatten
      end

      def self.preflights
        @preflights ||= []
      end

      def self.postflight(*klasses)
        postflights.replace preflights | klasses.flatten
      end

      def self.postflights
        @postflights ||= []
      end

      def initialize(*args)
        @config = Boxen::Config.load
        @flags  = Boxen::Flags.new(args).apply(@config)
        @args   = args
      end

      def invoke
        if self.class.preflights.all? { |p| p = p.new(@config); p.run unless p.ok? }
          self.run
          self.class.postflights.each { |p| p = p.new(@config); p.run unless p.ok? }
        end
      end

      def run
        raise "So your command #{self.class.name} hasn't defined a run method, so we dunno what to do. Sorry."
      end
    end
  end
end
