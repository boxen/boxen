module Boxen
  class Reporter
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def compare_url
      return unless config.reponame
      "https://github.com/#{config.reponame}/compare/#{sha}...master"
    end

    def hostname
      `hostname`.strip
    end

    def os
      `sw_vers -productVersion`.strip
    end

    def sha
      Dir.chdir(config.repodir) { `git rev-parse HEAD`.strip }
    end

    def shell
      ENV["SHELL"]
    end
  end
end
