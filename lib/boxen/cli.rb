require "boxen/command"

module Boxen
  class CLI
    def self.run(*args)
      cmd, cmd_args = args.flatten
      status = Boxen::Command.invoke cmd, *cmd_args

      return status.code
    end
  end
end
