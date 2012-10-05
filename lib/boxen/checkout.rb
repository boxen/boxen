module Boxen
  class Checkout
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def sha
      Dir.chdir(config.repodir) { `git rev-parse HEAD`.strip }
    end

    def master?
      Dir.chdir(config.repodir) { `git symbolic-ref HEAD`.strip == 'refs/heads/master' }
    end

    def dirty?
      !changes.empty?
    end

    def changes
      Dir.chdir(config.repodir) { `git status --porcelain`.strip }
    end
  end
end
