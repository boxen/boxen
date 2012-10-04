require "boxen/test"
require "boxen/reporter"

class BoxenReporterTest < Boxen::Test
  def setup
    @config   = mock "config"
    @reporter = Boxen::Reporter.new @config
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
    reporter = Boxen::Reporter.new :config
    assert_equal :config, reporter.config
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

    api = mock('api')
    api.expects(:create_issue).with(repo, "Failed for #{user}", details)
    @config.stubs(:api).returns(api)

    @reporter.record_failure
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

    @config.stubs(:reponame).returns('some/repo')
    compare = @reporter.compare_url

    details = @reporter.failure_details

    assert_match sha,      details
    assert_match hostname, details
    assert_match shell,    details
    assert_match os,       details
    assert_match compare,  details
  end
end
