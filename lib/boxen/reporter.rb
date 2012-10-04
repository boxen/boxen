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

    def log
      File.read @config.logfile
    end

    def record_failure
      @config.api.create_issue(@config.reponame, "Failed for #{@config.user}", failure_details)
    end

    def failure_details
      body = ''
      body << "Running on `#{hostname}` (OS X #{os}) under `#{shell}`, "
      body << "version #{sha} ([compare to master](#{compare_url}))."
      body << "\n\n"

      if config.dirty?
        body << "### Changes"
        body << "\n\n"
        body << "```\n#{config.changes}\n```"
        body << "\n\n"
      end 

      body << "### Output (from #{config.logfile})"
      body << "\n\n"
      body << "```\n#{log}\n```\n"

      body
    end
  end
end
