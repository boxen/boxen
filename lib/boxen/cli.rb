require "boxen/checkout"
require "boxen/config"
require "boxen/flags"
require "boxen/postflight"
require "boxen/preflight"
require "boxen/puppeteer"
require "boxen/reporter"
require "boxen/util"

module Boxen
  class CLI
    attr_reader :config
    attr_reader :flags
    attr_reader :puppet
    attr_reader :report

    def initialize(config, flags)
      @config = config
      @flags  = flags
      @puppet = Boxen::Puppeteer.new @config
      checkout = Boxen::Checkout.new(@config)
      @report = Boxen::Reporter.new(@config, checkout, @puppet)
    end

    def run

      # --env prints out the current BOXEN_ env vars.

      exec "env | grep ^BOXEN_ | sort" if flags.env?

      # --help prints some CLI help and exits.

      abort "#{flags}\n" if flags.help?

      # --projects prints a list of available projects and exits.

      if flags.projects?
        config.projects.each do |project|
          prefix = project.installed? ? "*" : " "
          puts "#{prefix} #{project.name}"
        end

        exit
      end

      # Actually run Puppet and return its exit code. FIX: Here's
      # where we'll reintegrate automatic error reporting.

      return puppet.run
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

      # Run the preflight checks.

      Boxen::Preflight.run config

      # Okay, we're gonna run Puppet. Let's make some dirs.

      Boxen::Util.sudo("mkdir", "-p", config.homedir) &&
        Boxen::Util.sudo("chown", "#{config.user}:staff", config.homedir)

      # Save the config for Puppet (and next time).

      Boxen::Config.save config

      # Make the magic happen.

      status = Boxen::CLI.new(config, flags).run

      # Run the postflight checks.

      Boxen::Postflight.run config if status.zero?

      # Return Puppet's exit status.

      return status
    end
  end
end
