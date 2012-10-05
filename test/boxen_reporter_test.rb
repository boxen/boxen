require "boxen/test"
require "boxen/reporter"

class BoxenReporterTest < Boxen::Test
  def setup
    @config   = mock "config"
    @puppet   = mock 'puppeteer'
    @checkout = mock 'checkout'
    @reporter = Boxen::Reporter.new @config, @checkout, @puppet
  end

  def test_compare_url
    @config.stubs(:reponame).returns "org/repo"
    @reporter.expects(:sha).returns "deadbeef"

    expected = "https://github.com/org/repo/compare/deadbeef...master"
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

  def test_sha
    @config.expects(:repodir).returns "test/fixtures/repo"
    @reporter.expects(:"`").with("git rev-parse HEAD").returns "deadbeef\n"
    assert_equal "deadbeef", @reporter.sha
  end

  def test_shell
    ENV.expects(:[]).with("SHELL").returns "/bin/crush"
    assert_equal "/bin/crush", @reporter.shell
  end

  def test_record_failure
    details = 'Everything went wrong.'
    @reporter.stubs(:failure_details).returns(details)

    repo = 'some/repo'
    user = 'hapless'
    @config.stubs(:reponame).returns(repo)
    @config.stubs(:user).returns(user)

    @reporter.failure_label = label = 'boom'

    api = mock('api')
    api.expects(:create_issue).with(repo, "Failed for #{user}", details, :labels => [label])
    @config.stubs(:api).returns(api)

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

  def test_failure_details
    sha = 'decafbad'
    @reporter.stubs(:sha).returns(sha)
    hostname = 'cools.local'
    @reporter.stubs(:hostname).returns(hostname)
    shell = '/bin/ksh'
    @reporter.stubs(:shell).returns(shell)
    os = '11.1.1'
    @reporter.stubs(:os).returns(os)
    log = "so\nmany\nthings\nto\nreport"
    @reporter.stubs(:log).returns(log)

    @config.stubs(:reponame).returns('some/repo')
    compare = @reporter.compare_url
    changes = 'so many changes'
    @checkout.stubs(:changes).returns(changes)
    @checkout.stubs(:dirty?).returns(true)

    commands = %w[/path/to/puppet apply stuff_and_things]
    @puppet.stubs(:command).returns(commands)
    command = commands.join(' ')

    logfile = '/path/to/logfile.txt'
    @config.stubs(:logfile).returns(logfile)

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
    logfile = '/path/to/logfile.txt'
    @config.stubs(:logfile).returns(logfile)

    log = 'a bunch of log data'
    File.expects(:read).with(logfile).returns(log)

    assert_equal log, @reporter.log
  end
end
