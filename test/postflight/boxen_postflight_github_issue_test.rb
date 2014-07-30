require 'boxen/test'
require 'boxen/postflight'
require 'boxen/postflight/github_issue'

class Boxen::Config
  attr_writer :api
end

class Boxen::Postflight::GithubIssue < Boxen::Postflight
  attr_writer :checkout
end

class BoxenPostflightGithubIssueTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new
    @checkout = Boxen::Checkout.new(@config)
    @command  = stub 'command', :success? => true
    @check    = Boxen::Postflight::GithubIssue.new @config, @command
    @check.checkout = @checkout
  end

  def test_enabled
    original = ENV['BOXEN_ISSUES_ENABLED']

    ENV['BOXEN_ISSUES_ENABLED'] = nil
    refute @check.enabled?

    ENV['BOXEN_ISSUES_ENABLED'] = 'duh'
    assert @check.enabled?

    ENV['BOXEN_ISSUES_ENABLED'] = original
  end

  def test_ok
    @check.stubs(:enabled?).returns(false)
    @checkout.stubs(:master?).returns(false)
    @config.stubs(:login).returns(nil)

    assert @check.ok?

    @check.stubs(:enabled?).returns(true)
    assert @check.ok?

    @checkout.stubs(:master?).returns(true)
    assert @check.ok?

    @config.stubs(:login).returns('')
    assert @check.ok?

    @config.stubs(:login).returns('somelogin')
    refute @check.ok?
  end

  def test_compare_url
    @config.reponame = repo = 'org/repo'
    sha = 'deadbeef'
    @checkout.expects(:sha).returns(sha)

    expected = "https://github.com/#{repo}/compare/#{sha}...master"
    assert_equal expected, @check.compare_url
  end

  def test_compare_url_ghurl
    @config.reponame = repo = 'org/repo'
    @config.ghurl = 'https://git.foo.com'
    sha = 'deadbeef'
    @checkout.expects(:sha).returns(sha)

    expected = "https://git.foo.com/#{repo}/compare/#{sha}...master"
    assert_equal expected, @check.compare_url
  end

  def test_hostname
    Socket.expects(:gethostname).returns("whatevs.local")
    assert_equal "whatevs.local", @check.hostname
  end

  def test_initialize
    check = Boxen::Postflight::GithubIssue.new :config, :command
    assert_equal :config,   check.config
    assert_equal :command,  check.command
  end

  def test_os
    @check.expects(:"`").with("sw_vers -productVersion").returns "11.1.1\n"
    assert_equal "11.1.1", @check.os
  end

  def test_shell
    val = ENV['SHELL']

    ENV['SHELL'] = '/bin/crush'
    assert_equal "/bin/crush", @check.shell

    ENV['SHELL'] = val
  end

  def test_record_failure
    @check.stubs(:issues?).returns(true)

    details = 'Everything went wrong.'
    @check.stubs(:failure_details).returns(details)

    @config.reponame = repo = 'some/repo'
    @config.user     = user = 'hapless'

    @check.failure_label = label = 'boom'

    @config.api = api = mock('api')
    api.expects(:create_issue).with(repo, "Failed for #{user}", details, :labels => [label])

    @check.record_failure
  end

  def test_record_failure_no_issues
    @check.stubs(:issues?).returns(false)

    @config.api = api = mock('api')
    api.expects(:create_issue).never

    @check.record_failure
  end

  def test_failure_label
    default = 'failure'
    assert_equal default, @check.failure_label

    @check.failure_label = label = 'oops'
    assert_equal label, @check.failure_label

    @check.failure_label = nil
    assert_equal default, @check.failure_label
  end

  def test_ongoing_label
    default = 'ongoing'
    assert_equal default, @check.ongoing_label

    @check.ongoing_label = label = 'checkit'
    assert_equal label, @check.ongoing_label

    @check.ongoing_label = nil
    assert_equal default, @check.ongoing_label
  end

  def test_failure_details
    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)
    hostname = 'cools.local'
    @check.stubs(:hostname).returns(hostname)
    shell = '/bin/ksh'
    @check.stubs(:shell).returns(shell)
    os = '11.1.1'
    @check.stubs(:os).returns(os)
    log = "so\nmany\nthings\nto\nreport"
    @check.stubs(:logfile).returns(log)

    @config.reponame = 'some/repo'
    compare = @check.compare_url
    changes = 'so many changes'
    @checkout.stubs(:changes).returns(changes)

    @config.logfile = logfile = '/path/to/logfile.txt'

    details = @check.failure_details

    assert_match sha,      details
    assert_match hostname, details
    assert_match shell,    details
    assert_match os,       details
    assert_match compare,  details
    assert_match changes,  details
    assert_match logfile,  details
    assert_match log,      details
  end

  def test_logfile
    @config.logfile = logfile = '/path/to/logfile.txt'

    log = 'a bunch of log data'
    File.expects(:read).with(logfile).returns(log)

    assert_equal log, @check.logfile
  end


  Issue = Struct.new(:number, :labels) do
    def labels
      self[:labels] || []
    end
  end
  Label = Struct.new(:name)

  def test_close_failures
    @check.stubs(:issues?).returns(true)

    @config.reponame = repo = 'some/repo'

    issues = Array.new(3) { |i|  Issue.new(i*2 + 2) }
    @check.stubs(:failures).returns(issues)

    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)

    @config.api = api = mock('api')
    issues.each do |issue|
      api.expects(:add_comment).with(repo, issue.number, "Succeeded at version #{sha}.")
      api.expects(:close_issue).with(repo, issue.number)
    end

    @check.close_failures
  end

  def test_close_failures_no_issues
    @check.stubs(:issues?).returns(false)

    @check.expects(:failures).never

    @config.api = api = mock('api')
    api.expects(:add_comment).never
    api.expects(:close_issue).never

    @check.close_failures
  end

  def test_failures
    @check.stubs(:issues?).returns(true)

    @config.reponame = repo = 'some/repo'
    @config.login    = user = 'hapless'

    @check.failure_label = fail_label = 'ouch'
    @check.ongoing_label = goon_label = 'goon'

    fail_l = Label.new(fail_label)
    goon_l = Label.new(goon_label)
    pop_l  = Label.new('popcorn')

    issues = [
      Issue.new(0, [fail_l]),
      Issue.new(1, [fail_l, pop_l]),
      Issue.new(2, [fail_l, goon_l]),
      Issue.new(3, [fail_l, Label.new('bang')]),
      Issue.new(4, [fail_l, goon_l, pop_l]),
    ]

    @config.api = api = mock('api')
    api.expects(:list_issues).with(repo, :state => 'open', :labels => fail_label, :creator => user).returns(issues)

    assert_equal issues.values_at(0,1,3), @check.failures
  end

  def test_failures_no_issues
    @check.stubs(:issues?).returns(false)

    @config.api = api = mock('api')
    api.expects(:list_issues).never

    assert_equal [], @check.failures
  end

  RepoInfo = Struct.new(:has_issues)
  def test_issues?
    @config.reponame = repo = 'some/repo'

    repo_info = RepoInfo.new(true)

    @config.api = api = mock('api')
    api.stubs(:repository).with(repo).returns(repo_info)
    assert @check.issues?

    repo_info = RepoInfo.new(false)
    api.stubs(:repository).with(repo).returns(repo_info)
    refute @check.issues?

    @config.stubs(:reponame)  # to ensure the returned value is nil
    api.stubs(:repository).returns(RepoInfo.new(true))
    refute @check.issues?

    @config.stubs(:reponame).returns('boxen/our-boxen') # our main public repo
    api.stubs(:repository).returns(RepoInfo.new(true))
    refute @check.issues?
  end
end
