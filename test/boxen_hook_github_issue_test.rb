require "boxen/test"
require "boxen/hook/github_issue"

class Boxen::Config
  attr_writer :api
end

class BoxenHookGitHubIssueTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new
    @checkout = Boxen::Checkout.new(@config)
    @puppet   = mock 'puppeteer'
    @result   = stub 'result', :success? => true
    @hook = Boxen::Hook::GitHubIssue.new @config, @checkout, @puppet, @result
  end

  def test_enabled
    original = ENV['BOXEN_ISSUES_ENABLED']

    ENV['BOXEN_ISSUES_ENABLED'] = nil
    refute @hook.enabled?

    ENV['BOXEN_ISSUES_ENABLED'] = 'duh'
    assert @hook.enabled?

    ENV['BOXEN_ISSUES_ENABLED'] = original
  end

  def test_perform
    @hook.stubs(:enabled?).returns(false)
    @config.stubs(:stealth?).returns(true)
    @config.stubs(:pretend?).returns(true)
    @checkout.stubs(:master?).returns(false)
    @config.stubs(:login).returns(nil)

    refute @hook.perform?

    @hook.stubs(:enabled?).returns(true)
    refute @hook.perform?

    @config.stubs(:stealth?).returns(false)
    refute @hook.perform?

    @config.stubs(:pretend?).returns(false)
    refute @hook.perform?

    @checkout.stubs(:master?).returns(true)
    refute @hook.perform?

    @config.stubs(:login).returns('')
    refute @hook.perform?

    @config.stubs(:login).returns('somelogin')
    assert @hook.perform?
  end

  def test_compare_url
    @config.reponame = repo = 'org/repo'
    sha = 'deadbeef'
    @checkout.expects(:sha).returns(sha)

    expected = "https://github.com/#{repo}/compare/#{sha}...master"
    assert_equal expected, @hook.compare_url
  end

  def test_compare_url_ghurl
    @config.reponame = repo = 'org/repo'
    @config.ghurl = 'https://git.foo.com'
    sha = 'deadbeef'
    @checkout.expects(:sha).returns(sha)

    expected = "https://git.foo.com/#{repo}/compare/#{sha}...master"
    assert_equal expected, @hook.compare_url
  end

  def test_hostname
    @hook.expects(:"`").with("hostname").returns "whatevs.local\n"
    assert_equal "whatevs.local", @hook.hostname
  end

  def test_initialize
    hook = Boxen::Hook::GitHubIssue.new :config, :checkout, :puppet, :result
    assert_equal :config,   hook.config
    assert_equal :checkout, hook.checkout
    assert_equal :puppet,   hook.puppet
    assert_equal :result,   hook.result
  end

  def test_os
    @hook.expects(:"`").with("sw_vers -productVersion").returns "11.1.1\n"
    assert_equal "11.1.1", @hook.os
  end

  def test_shell
    val = ENV['SHELL']

    ENV['SHELL'] = '/bin/crush'
    assert_equal "/bin/crush", @hook.shell

    ENV['SHELL'] = val
  end

  def test_record_failure
    @hook.stubs(:issues?).returns(true)

    details = 'Everything went wrong.'
    @hook.stubs(:failure_details).returns(details)

    @config.reponame = repo = 'some/repo'
    @config.user     = user = 'hapless'

    @hook.failure_label = label = 'boom'

    @config.api = api = mock('api')
    api.expects(:create_issue).with(repo, "Failed for #{user}", details, :labels => [label])

    @hook.record_failure
  end

  def test_record_failure_no_issues
    @hook.stubs(:issues?).returns(false)

    @config.api = api = mock('api')
    api.expects(:create_issue).never

    @hook.record_failure
  end

  def test_failure_label
    default = 'failure'
    assert_equal default, @hook.failure_label

    @hook.failure_label = label = 'oops'
    assert_equal label, @hook.failure_label

    @hook.failure_label = nil
    assert_equal default, @hook.failure_label
  end

  def test_ongoing_label
    default = 'ongoing'
    assert_equal default, @hook.ongoing_label

    @hook.ongoing_label = label = 'checkit'
    assert_equal label, @hook.ongoing_label

    @hook.ongoing_label = nil
    assert_equal default, @hook.ongoing_label
  end

  def test_failure_details
    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)
    hostname = 'cools.local'
    @hook.stubs(:hostname).returns(hostname)
    shell = '/bin/ksh'
    @hook.stubs(:shell).returns(shell)
    os = '11.1.1'
    @hook.stubs(:os).returns(os)
    log = "so\nmany\nthings\nto\nreport"
    @hook.stubs(:log).returns(log)

    @config.reponame = repo = 'some/repo'
    compare = @hook.compare_url
    changes = 'so many changes'
    @checkout.stubs(:changes).returns(changes)

    commands = %w[/path/to/puppet apply stuff_and_things]
    @puppet.stubs(:command).returns(commands)
    command = commands.join(' ')

    @config.logfile = logfile = '/path/to/logfile.txt'

    details = @hook.failure_details

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

    assert_equal log, @hook.log
  end


  Issue = Struct.new(:number, :labels) do
    def labels
      self[:labels] || []
    end
  end
  Label = Struct.new(:name)

  def test_close_failures
    @hook.stubs(:issues?).returns(true)

    @config.reponame = repo = 'some/repo'

    issues = Array.new(3) { |i|  Issue.new(i*2 + 2) }
    @hook.stubs(:failures).returns(issues)

    sha = 'decafbad'
    @checkout.stubs(:sha).returns(sha)

    @config.api = api = mock('api')
    issues.each do |issue|
      api.expects(:add_comment).with(repo, issue.number, "Succeeded at version #{sha}.")
      api.expects(:close_issue).with(repo, issue.number)
    end

    @hook.close_failures
  end

  def test_close_failures_no_issues
    @hook.stubs(:issues?).returns(false)

    @hook.expects(:failures).never

    @config.api = api = mock('api')
    api.expects(:add_comment).never
    api.expects(:close_issue).never

    @hook.close_failures
  end

  def test_failures
    @hook.stubs(:issues?).returns(true)

    @config.reponame = repo = 'some/repo'
    @config.login    = user = 'hapless'

    @hook.failure_label = fail_label = 'ouch'
    @hook.ongoing_label = goon_label = 'goon'

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

    assert_equal issues.values_at(0,1,3), @hook.failures
  end

  def test_failures_no_issues
    @hook.stubs(:issues?).returns(false)

    @config.api = api = mock('api')
    api.expects(:list_issues).never

    assert_equal [], @hook.failures
  end

  RepoInfo = Struct.new(:has_issues)
  def test_issues?
    @config.reponame = repo = 'some/repo'

    repo_info = RepoInfo.new(true)

    @config.api = api = mock('api')
    api.stubs(:repository).with(repo).returns(repo_info)
    assert @hook.issues?

    repo_info = RepoInfo.new(false)
    api.stubs(:repository).with(repo).returns(repo_info)
    refute @hook.issues?

    @config.stubs(:reponame)  # to ensure the returned value is nil
    api.stubs(:repository).returns(RepoInfo.new(true))
    refute @hook.issues?

    @config.stubs(:reponame).returns('boxen/our-boxen') # our main public repo
    api.stubs(:repository).returns(RepoInfo.new(true))
    refute @hook.issues?
  end
end
