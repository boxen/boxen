require "boxen"

module Boxen
  class CLI
    attr_reader :config
    attr_reader :flags
    attr_reader :puppet

    def initialize(config, flags)
      @config = config
      @flags  = flags
      @puppet = Boxen::Puppeteer.new @config
    end
  end
end
