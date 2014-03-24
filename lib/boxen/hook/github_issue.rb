require "boxen/hook"

module Boxen
  class Hook
    class GitHubIssue < Hook
      def perform?
        enabled? &&
        !config.stealth? && !config.pretend? &&
        !config.login.to_s.empty? &&
        checkout.master?
      end

      def call
        if result.success?
          close_failures
        else
          warn "Sorry! Creating an issue on #{config.reponame}."
          record_failure
        end
      end

      def compare_url
        return unless config.reponame
        "#{config.ghurl}/#{config.reponame}/compare/#{checkout.sha}...master"
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
        return unless issues?

        title = "Failed for #{config.user}"
        config.api.create_issue(config.reponame, title, failure_details,
          :labels => [failure_label])
      end

      def close_failures
        return unless issues?

        comment = "Succeeded at version #{checkout.sha}."
        failures.each do |issue|
          config.api.add_comment(config.reponame, issue.number, comment)
          config.api.close_issue(config.reponame, issue.number)
        end
      end

      def failures
        return [] unless issues?

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
        return unless config.reponame
        return if config.reponame == 'boxen/our-boxen'

        config.api.repository(config.reponame).has_issues
      end

      private
      def required_environment_variables
        ['BOXEN_ISSUES_ENABLED']
      end
    end
  end
end

Boxen::Hook.register Boxen::Hook::GitHubIssue
