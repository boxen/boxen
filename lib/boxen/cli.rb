require "boxen/command"
require "boxen/config"

module Boxen
  class CLI
    def self.run(*args)
      cmd, *cmd_args = args.flatten
      config = Boxen::Config.load
      status = Boxen::Command.invoke cmd, config, *cmd_args

      return status.code
    end
  end
end
