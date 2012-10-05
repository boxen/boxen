require "boxen/test"
require "boxen/config"

class BoxenConfigTest < Boxen::Test
  def setup
    @config = Boxen::Config.new
    @config.repodir = "test/fixtures/repo"
  end

  def test_debug?
    refute @config.debug?

    @config.debug = true
    assert @config.debug?
  end

  def test_email
    assert_nil @config.email

    @config.email = "foo"
    assert_equal "foo", @config.email
  end

  def test_fde?
    assert @config.fde?

    @config.fde = false
    refute @config.fde?
  end

  def test_fde_env_var
    ENV.expects(:[]).with("BOXEN_NO_FDE").returns "1"
    refute @config.fde?
  end

  def test_homedir
    assert_equal "/opt/boxen", @config.homedir

    @config.homedir = "foo"
    assert_equal "foo", @config.homedir
  end

  def test_homedir_env_var_boxen_home
    ENV.expects(:[]).with("BOXEN_HOME").returns "foo"
    assert_equal "foo", @config.homedir
  end

def test_initialize
    config = Boxen::Config.new do |c|
      c.homedir = "foo"
    end

    assert_equal "foo", config.homedir
  end

  def test_logfile
    assert_equal "#{@config.repodir}/log/boxen.log", @config.logfile

    @config.logfile = "foo"
    assert_equal "foo", @config.logfile
  end

  def test_logfile_env_var
    ENV.expects(:[]).with("BOXEN_LOG_FILE").returns "foo"
    assert_equal "foo", @config.logfile
  end

  def test_login
    assert_nil @config.login

    @config.login = "foo"
    assert_equal "foo", @config.login
  end

  def test_name
    assert_nil @config.name

    @config.name = "foo"
    assert_equal "foo", @config.name
  end

  def test_password
    assert_nil @config.password

    @config.password = "foo"
    assert_equal "foo", @config.password
  end

  def test_pretend?
    refute @config.pretend?

    @config.pretend = true
    assert @config.pretend?
  end

  def test_profile?
    refute @config.profile?

    @config.profile = true
    assert @config.profile?
  end

  def test_projects
    files = Dir["#{@config.repodir}/modules/projects/manifests/*.pp"]
    assert_equal files.size, @config.projects.size
  end

  def test_puppetdir
    assert_equal "/tmp/boxen/puppet", @config.puppetdir
  end

  def test_puppetdir_env_var
    ENV.expects(:[]).with("BOXEN_PUPPET_DIR").returns "foo"
    assert_equal "foo", @config.puppetdir
  end

  def test_repodir
    @config.repodir = nil
    assert_equal Dir.pwd, @config.repodir

    @config.repodir = "foo"
    assert_equal "foo", @config.repodir
  end

  def test_repodir_env_var
    @config.repodir = nil

    ENV.expects(:[]).with("BOXEN_REPO_DIR").returns "foo"
    assert_equal "foo", @config.repodir
  end

  def test_reponame
    @config.reponame = "something/explicit"
    assert_equal "something/explicit", @config.reponame
  end

  def test_reponame_env_var
    ENV.expects(:[]).with("BOXEN_REPO_NAME").returns "env/var"
    assert_equal "env/var", @config.reponame
  end

  def test_reponame_git_config
    @config.expects(:"`").with("git config remote.origin.url").
      returns "https://github.com/some-org/our-boxen\n"

    assert_equal "some-org/our-boxen", @config.reponame
  end

  def test_reponame_git_config_bad_exit
    @config.expects(:"`").with("git config remote.origin.url").returns ""
    $?.expects(:success?).returns false

    assert_nil @config.reponame
  end

  def test_reponame_git_config_bad_url
    @config.expects(:"`").with("git config remote.origin.url").
      returns "https://spumco.com/some-org/our-boxen\n"

    assert_nil @config.reponame
  end

  def test_reponame_git_config_git_extension
    @config.expects(:"`").with("git config remote.origin.url").
      returns "https://github.com/some-org/our-boxen.git\n"

    assert_equal "some-org/our-boxen", @config.reponame
  end

  def test_srcdir
    @config.expects(:user).returns "foo"
    assert_equal "/Users/foo/src", @config.srcdir

    @config.srcdir = "elsewhere"
    assert_equal "elsewhere", @config.srcdir
  end

  def test_stealth?
    refute @config.stealth?

    @config.stealth = true
    assert @config.stealth?
  end

  def test_stealth_env_var
    ENV.expects(:[]).with("BOXEN_NO_ISSUE").returns "1"
    assert @config.stealth?
  end

  def test_token
    assert_nil @config.token

    @config.token = "foo"
    assert_equal "foo", @config.token
  end

  def test_user
    ENV.expects(:[]).with("USER").returns "foo"
    assert_equal "foo", @config.user

    @config.user = "bar"
    assert_equal "bar", @config.user
  end

  def test_api
    @config.login    = login = 'someuser'
    @config.password = pass  = 's3kr!7'

    api = Object.new
    Octokit::Client.expects(:new).with(:login => login, :password => pass).once.returns(api)

    assert_equal api, @config.api
    assert_equal api, @config.api  # This extra call plus the `once` on the expectation is for the ivar cache.
  end
end
