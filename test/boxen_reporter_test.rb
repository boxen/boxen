require "boxen/test"
require "boxen/reporter"

class Boxen::Config
  attr_writer :api
end

class BoxenReporterTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new
    @checkout = Boxen::Checkout.new(@config)
    @puppet   = mock 'puppeteer'
    @reporter = Boxen::Reporter.new @config, @checkout, @puppet
  end

  def test_compare_url
    @config.reponame = repo = 'org/repo'
    sha = 'deadbeef'
    @checkout.expects(:sha).returns(sha)

    expected = "https://github.com/#{repo}/compare/#{sha}...master"
    assert_equal expected, @reporter.compare_url
  end

  def test_hostname
    @reporter.expects(:"`").with("hostname").returns "whatevs.local\n"
    assert_equal "whatevs.local", @reporter.hostname
  end

  def test_initialize
    reporter = Boxen::Reporter.new :config, :checkout, :puppet
    assert_equal :config,   reporter.config
    assert_equal :checkout, reporter.checkout
    assert_equal :puppet,   reporter.puppet
  end

  def test_os
    @reporter.expects(:"`").with("sw_vers -productVersion").returns "11.1.1\n"
    assert_equal "11.1.1", @reporter.os
  end

  def test_shell
    val = ENV['SHELL']

    ENV['SHELL'] = '/bin/crush'
    assert_equal "/bin/crush", @reporter.shell

    ENV['SHELL'] = val
  end

  def test_record_failure
    details = 'Everything went wrong.'
    @reporter.stubs(:failure_details).returns(details)

    @config.reponame = repo = 'some/repo'
    @config.user     = user = 'hapless'

    @reporter.failure_label = label = 'boom'

    @config.api = api = mock('api')
    api.expects(:create_issue).with(repo, "Failed for #{user}", details, :labels => [label])

    @reporter.record_failure
  end

  def test_failure_label
    default = 'failure'
    assert_equal default, @reporter.failure_label

    @reporter.failure_label = label = 'oops'
    assert_equal label, @reporter.failure_label

    @reporter.failure_label = nil
    assert_equal default, @reporter.failure_label
  end

  def test_ongoing_label
    default = 'ongoing'
    assert_equal default, @reporter.ongoing_label

    @reporter.ongoing_label = label = 'checkit'
    assert_equal label, @reporter.ongoing_label

    @reporter.ongoing_label = nil
    assert_equal default, @reporter.ongoing_label
  end

  def test_failure_details
    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)
    hostname = 'cools.local'
    @reporter.stubs(:hostname).returns(hostname)
    shell = '/bin/ksh'
    @reporter.stubs(:shell).returns(shell)
    os = '11.1.1'
    @reporter.stubs(:os).returns(os)
    log = "so\nmany\nthings\nto\nreport"
    @reporter.stubs(:log).returns(log)

    @config.reponame = repo = 'some/repo'
    compare = @reporter.compare_url
    changes = 'so many changes'
    @checkout.stubs(:changes).returns(changes)

    commands = %w[/path/to/puppet apply stuff_and_things]
    @puppet.stubs(:command).returns(commands)
    command = commands.join(' ')

    @config.logfile = logfile = '/path/to/logfile.txt'

    details = @reporter.failure_details

    assert_match sha,      details
    assert_match hostname, details
    assert_match shell,    details
    assert_match os,       details
    assert_match compare,  details
    assert_match changes,  details
    assert_match command,  details
    assert_match logfile,  details
    assert_match log,      details
  end

  def test_log
    @config.logfile = logfile = '/path/to/logfile.txt'

    log = 'a bunch of log data'
    File.expects(:read).with(logfile).returns(log)

    assert_equal log, @reporter.log
  end

  def test_close_failures
    @config.reponame = repo = 'some/repo'

    issues = Array.new(3) { |i|  stub('issue', :number => i*2 + 2) }
    @reporter.stubs(:failures).returns(issues)

    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)

    @config.api = api = mock('api')
    issues.each do |issue|
      api.expects(:add_comment).with(repo, issue.number, "Succeeded at version #{sha}.")
      api.expects(:close_issue).with(repo, issue.number)
    end

    @reporter.close_failures
  end

  def test_failures
    @config.reponame = repo = 'some/repo'
    @config.login    = user = 'hapless'

    @reporter.failure_label = fail_label = 'ouch'
    @reporter.ongoing_label = goon_label = 'goon'

    issues = [
      stub('issue', :labels => [stub('label', :name => fail_label)]),
      stub('issue', :labels => [stub('label', :name => fail_label), stub('label', :name => 'popcorn')]),
      stub('issue', :labels => [stub('label', :name => fail_label), stub('label', :name => goon_label)]),
      stub('issue', :labels => [stub('label', :name => fail_label), stub('label', :name => 'bang')]),
      stub('issue', :labels => [stub('label', :name => fail_label), stub('label', :name => goon_label), stub('label', :name => 'popcorn')]),
    ]

    @config.api = api = mock('api')
    api.expects(:list_issues).with(repo, :state => 'open', :labels => fail_label, :creator => user).returns(issues)

    assert_equal issues.values_at(0,1,3), @reporter.failures
  end
end
