require "boxen/commands"
require "boxen/command_status"
require "boxen/config"
require "boxen/flags"
require "boxen/preflight"
require "boxen/postflight"

module Boxen
  class Command
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
      if preflights?
        cmd_status = self.run

        postflights? if cmd_status.success?

        cmd_status
      end
    end

    def run
      raise "So your command #{self.class.name} hasn't defined a run method, so we dunno what to do. Sorry."
    end

    def preflights?
      if self.class.preflights.any? && !@config.debug?
        puts "Performing preflight checks"
      end

      self.class.preflights.all? do |p|
        p = p.new(@config)
        status = p.ok?

        if status
          puts "Passed preflight check: #{p.class.name}" if @config.debug?
        else
          p.run
        end

        status
      end
    end

    def postflights?
      if self.class.postflights.any? && !@config.debug?
        puts "Performing postflight checks"
      end

      self.class.postflights.each do |p|
        p = p.new(@config)
        p.run unless p.ok?
      end
    end
  end
end
