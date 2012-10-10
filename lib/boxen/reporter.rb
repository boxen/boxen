module Boxen
  class Reporter
    attr_reader :config
    attr_reader :checkout
    attr_reader :puppet

    def initialize(config, checkout, puppet)
      @config   = config
      @checkout = checkout
      @puppet   = puppet
    end

    def compare_url
      return unless config.reponame
      "https://github.com/#{config.reponame}/compare/#{checkout.sha}...master"
    end

    def hostname
      `hostname`.strip
    end

    def os
      `sw_vers -productVersion`.strip
    end

    def shell
      ENV["SHELL"]
    end

    def log
      File.read config.logfile
    end

    def record_failure
      title = "Failed for #{config.user}"
      config.api.create_issue(config.reponame, title, failure_details,
        :labels => [failure_label])
    end

    def close_failures
      comment = "Succeeded at version #{checkout.sha}."
      failures.each do |issue|
        config.api.add_comment(config.reponame, issue.number, comment)
        config.api.close_issue(config.reponame, issue.number)
      end
    end

    def failures
      issues = config.api.list_issues(config.reponame, :state => 'open',
        :labels => failure_label, :creator => config.login)
      issues.reject! {|i| i.labels.collect(&:name).include?(ongoing_label)}
      issues
    end

    def failure_details
      body = ''
      body << "Running on `#{hostname}` (OS X #{os}) under `#{shell}`, "
      body << "version #{checkout.sha} ([compare to master](#{compare_url}))."
      body << "\n\n"

      if checkout.dirty?
        body << "### Changes"
        body << "\n\n"
        body << "```\n#{checkout.changes}\n```"
        body << "\n\n"
      end 

      body << "### Puppet Command"
      body << "\n\n"
      body << "```\n#{puppet.command.join(' ')}\n```"
      body << "\n\n"

      body << "### Output (from #{config.logfile})"
      body << "\n\n"
      body << "```\n#{log}\n```\n"

      body
    end

    def failure_label
      @failure_label ||= 'failure'
    end
    attr_writer :failure_label

    def ongoing_label
      @ongoing_label ||= 'ongoing'
    end
    attr_writer :ongoing_label

    def issues?
      config.api.repository(config.reponame).has_issues
    end
  end
end
