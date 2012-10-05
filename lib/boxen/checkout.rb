module Boxen
  class Checkout
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def dirty?
      !changes.empty?
    end

    def changes
      Dir.chdir(config.repodir) { `git status --porcelain`.strip }
    end
  end
end
