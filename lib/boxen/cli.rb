require 'boxen/config'
require 'boxen/flags'
require 'boxen/postflight'
require 'boxen/preflight'
require 'boxen/runner'
require 'boxen/util'

module Boxen
  class CLI
    attr_reader :config
    attr_reader :flags
    attr_reader :runner

    def initialize(config, flags)
      @config = config
      @flags  = flags
      @runner = Boxen::Runner.new(@config, @flags)
    end

    def run
      if flags.help?
        puts flags
        exit
      end

      runner.run
    end

    # Run Boxen by wiring together the command-line flags, config,
    # preflights, Puppet execution, and postflights. Returns Puppet's
    # exit code.

    def self.run(*args)
      config = Boxen::Config.load
      flags  = Boxen::Flags.new args

      # Apply command-line flags to the config in case we're changing or
      # overriding anything.
      flags.apply config

      run_preflight_checks if flags.run?
      run_postflight_checks if flags.run? && status.success?

      status.code
    end

    def run_preflight_checks
      Boxen::Preflight.run config
      Boxen::Config.save config
    end

    def run_postflight_checks
      Boxen::Postflight.run config
    end

    def status
      Boxen::CLI.new(config, flags).run
    end
  end
end
