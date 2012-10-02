require "ansi"

module Boxen

  # The superclass for preflight and postflight sanity checks.

  class Check

    # A collection of preflight instances for `config`. An instance is
    # created for every constant under `self` that's also a
    # subclass of `self`.

    def self.checks(config)
      constants.map { |n| const_get n }.
        select { |c| c < self }.
        map { |c| c.new config }
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

    def initialize(config)
      @config = config
    end

    # Is everything good to go? Implemented by subclasses.

    def ok?
      raise "Subclasses must implement this method."
    end

    # Warn, fix, or abort. Implemented by subclasses.

    def run
      raise "Subclasses must implement this method."
    end

    # A fancier `abort` and `warn`. This will probably really annoy
    # someone at some point because it's overriding a Kernel method,
    # but it's limited to checks.

    def abort(message, *extras)
      extras << { :color => :red }
      warn message, *extras
      exit 1
    end

    def warn(message, *extras)
      options = Hash === extras.last ? extras.pop : {}
      color   = options[:color] || :yellow

      $stderr.puts ANSI.send(color) { "--> #{message}" }

      unless extras.empty?
        extras.each { |line| $stderr.puts "    #{line}" }
      end

      $stderr.puts
    end
  end
end
