require "boxen/config"
require "boxen/flags"
require "boxen/preflight"
require "boxen/postflight"

module Boxen

  # Is Boxen active?

  def self.active?
    ENV.include? "BOXEN_HOME"
  end

  # Run Boxen by wiring together the command-line flags, config,
  # preflights, Puppet execution, and postflights. Returns Puppet's
  # exit code.

  def self.run *args
    config = Boxen::Config.load
    flags  = Boxen::Flags.new args

    # Apply command-line flags to the config in case we're changing or
    # overriding anything.

    flags.apply config

    # Run the preflight checks.

    Boxen::Preflight.run config

    # Save the config for Puppet (and next time).

    Boxen::Config.save config

    # Make the magic happen.

    code = 0#Boxen::CLI.new(config, flags).run

    # Run the postflight checks.

    Boxen::Postflight.run config if code.zero?

    p :config => config

    return code
  end

  # Run `args` as a system command with sudo if necessary.

  def self.sudo *args
    system "sudo", "-p", "Password for sudo: ", *args
  end
end
