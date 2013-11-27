require "boxen/config"
require "boxen/command"
require "boxen/flags"
require "boxen/postflight"
require "boxen/preflight"
require "boxen/runner"
require "boxen/util"

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

    def self.run(*args)
      cmd, cmd_args = args.flatten
      status = Boxen::Command.invoke cmd, *cmd_args

      return status.code
    end
  end
end
