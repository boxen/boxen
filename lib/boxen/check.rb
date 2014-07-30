require "boxen/util/logging"

module Boxen

  # The superclass for preflight and postflight sanity checks.

  class Check
    include Boxen::Util::Logging

    # Search `dir` and load all Ruby files under it.

    def self.register(dir)
      Dir["#{dir}/*.rb"].sort.each { |f| load f }
    end

    attr_reader :config
    attr_reader :command

    def initialize(config, command)
      @config  = config
      @command = command
    end

    # Is everything good to go? Implemented by subclasses.

    def ok?
      raise "Subclasses must implement this method."
    end

    # Warn, fix, or abort. Implemented by subclasses.

    def run
      raise "Subclasses must implement this method."
    end


    def debug?
      @config.debug?
    end
  end
end
