require "boxen/command"
require "boxen/config"
require "boxen/util/logging"

module Boxen
  class CLI
    include Boxen::Util::Logging

    def self.run(*args)
      new.run(*args)
    end

    def initialize
    end

    def run(*args)
      cmd, *cmd_args = args.flatten

      with_friendly_errors do
        config = Boxen::Config.load
        status = Boxen::Command.invoke cmd, config, *cmd_args

        status.code
      end
    end

    private

    def with_friendly_errors(&block)
      yield
    rescue => e
      abort "#{e.class.name}: #{e.message}"
    end
  end
end
