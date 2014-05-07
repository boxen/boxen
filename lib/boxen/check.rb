require "boxen/util/logging"

module Boxen

  # The superclass for preflight and postflight sanity checks.

  class Check
    include Boxen::Util::Logging

    # A collection of preflight instances for `config`. An instance is
    # created for every constant under `self` that's also a
    # subclass of `self`.

    def self.checks(config, command)
      constants.map { |n| const_get n }.
        select { |c| c < self }.
        map { |c| c.new config, command }
    end

    # Search `dir` and load all Ruby files under it.

    def self.register(dir)
      Dir["#{dir}/*.rb"].sort.each { |f| load f }
    end

    # Check each instance against `config`.

    def self.run(config)
      checks(config).each { |check| check.run unless check.ok? }
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
