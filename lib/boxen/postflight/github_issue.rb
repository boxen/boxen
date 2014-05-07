require "boxen/postflight"
require "boxen/checkout"

# Checks to see if the basic environment is loaded.

class Boxen::Postflight::GithubIssue < Boxen::Postflight
  attr_reader :checkout

  def initialize(*args)
    super(*args)
    @checkout = Boxen::Checkout.new(config)
  end

  def ok?
    # Only run if we have credentials and we're on master
    config.login.to_s.empty? && !checkout.master?
  end

  def run
    if command.success?
      close_failures
    else
      warn "Sorry! Creatinga n issue on #{config.reponame}"
      record_failure
    end
  end

  private
  def compare_url
    return unless config.reponame
    "#{config.ghurl}/#{config.reponame}/compare/#{checkout.sha}...master"
  end

  def hostname
    Socket.gethostname
  end

  def os
    `sw_vers -productVersion`.strip
  end

  def shell
    ENV["SHELL"]
  end

  def logfile
    File.read config.logfile
  end

  def record_failure
    return unless issues?

    title = "Failed for #{config.user}"
    config.api.create_issue config.reponame,
      title,
      failure_details,
      :labels => [
        failure_label
      ]
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

    body << "### Output (from #{config.logfile})"
    body << "\n\n"
    body << "```\n#{logfile}\n```\n"

    body
  end

  def failure_label
    @failure_label ||= 'failure'
  end

  def ongoing_label
    @ongoing_label ||= 'ongoing'
  end

  def issues?
    return unless config.reponame
    return if config.reponame == 'boxen/our-boxen'

    config.api.repository(config.reponame).has_issues
  end

  def required_environment_variables
    ['BOXEN_ISSUES_ENABLED']
  end

  def enabled?
    required_vars = Array(required_environment_variables)
    required_vars.any? && required_vars.all? do |var|
      ENV[var] && !ENV[var].empty?
    end
  end
end
