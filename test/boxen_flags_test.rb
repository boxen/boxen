require "boxen/test"
require "boxen/flags"

class BoxenFlagsTest < Boxen::Test
  def test_apply
    config = mock do
      expects(:debug=).with true

      stubs(:fde?).returns true
      expects(:fde=).with false

      expects(:homedir=).with "homedir"
      expects(:logfile=).with "logfile"
      expects(:login=).with "login"
      expects(:token=).with "token"
      expects(:pretend=).with true
      expects(:profile=).with true
      expects(:future_parser=).with true
      expects(:report=).with true
      expects(:graph=).with true
      expects(:srcdir=).with "srcdir"
      expects(:stealth=).with true
      expects(:user=).with "user"
      expects(:color=).with true
    end

    # Do our best to frob every switch.

    flags = Boxen::Flags.new "--debug", "--help", "--login", "login",
      "--no-fde", "--no-pull", "--no-issue", "--noop",
      "--pretend", "--profile", "--future-parser", "--report", "--graph", "--projects",
      "--user", "user", "--homedir", "homedir", "--srcdir", "srcdir",
      "--logfile", "logfile", "--token", "token"

    assert_same config, flags.apply(config)
  end

  def test_args
    config = flags "--debug", "foo"
    assert_equal %w(foo), config.args
  end

  def test_debug
    refute flags.debug?
    assert flags("--debug").debug?
  end

  def test_env?
    refute flags.env?
    assert flags("--env").env?
  end

  def test_help
    refute flags.help?

    %w(--help -h -?).each do |flag|
      assert flags(flag).help?
    end
  end

  def test_disable_services?
    refute flags.disable_services?
    assert flags("--disable-services").disable_services?
  end

  def test_enable_services?
    refute flags.enable_services?
    assert flags("--enable-services").enable_services?
  end

  def test_list_services?
    refute flags.list_services?
    assert flags("--list-services").list_services?
  end

  def test_homedir
    assert_nil flags.homedir
    assert_equal "foo", flags("--homedir", "foo").homedir
  end

  def test_initialize_bad_option
    ex = assert_raises Boxen::Error do
      flags "--bad-option"
    end

    assert_match "invalid option", ex.message
    assert_match "--bad-option", ex.message
  end

  def test_initialize_dups
    args  = %w(foo)
    config = flags args

    assert_equal args, config.args
    refute_same args, config.args
  end

  def test_initialize_empty
    config = flags
    assert_equal [], config.args
  end

  def test_initialize_flattens
    config = flags "foo", ["bar"]
    assert_equal %w(foo bar), config.args
  end

  def test_initialize_nils
    config = flags "foo", nil, "bar"
    assert_equal %w(foo bar), config.args
  end

  def test_initialize_strings
    config = flags :foo, [:bar]
    assert_equal %w(foo bar), config.args
  end

  def test_logfile
    assert_nil flags.logfile
    assert_equal "foo", flags("--logfile", "foo").logfile
  end

  def test_login
    assert_nil flags.login
    assert_equal "jbarnette", flags("--login", "jbarnette").login
  end

  def test_no_fde
    assert flags.fde?
    refute flags("--no-fde").fde?
  end

  def test_no_pull_is_a_noop
    flags "--no-pull"
  end

  def test_parse
    config = flags
    config.parse "--debug", "foo"

    assert config.debug?
    assert_equal %w(foo), config.args
  end

  def test_token
    assert_nil flags.token
    assert_equal "foo", flags("--token", "foo").token
  end

  def test_token_missing_value
    ex = assert_raises Boxen::Error do
      flags "--token"
    end

    assert_match "missing argument", ex.message
  end

  def test_pretend
    refute flags.pretend?
    assert flags("--noop").pretend?
    assert flags("--pretend").pretend?
  end

  def test_profile
    refute flags.profile?
    assert flags("--profile").profile?
  end

  def test_future_parser
    refute flags.future_parser?
    assert flags("--future-parser").future_parser?
  end

  def test_report
    refute flags.report?
    assert flags("--report").report?
  end

  def test_graph
    refute flags.graph?
    assert flags("--graph").graph?
  end

  def test_projects
    refute flags.projects?
    assert flags("--projects").projects?
  end

  def test_srcdir
    assert_nil flags.srcdir
    assert_equal "foo", flags("--srcdir", "foo").srcdir
  end

  def test_stealth
    refute flags.stealth?
    assert flags("--no-issue").stealth?
    assert flags("--stealth").stealth?
  end

  def test_user
    assert_equal "jbarnette", flags("--user", "jbarnette").user
  end

  def test_user_missing_value
    ex = assert_raises Boxen::Error do
      flags "--user"
    end

    assert_match "missing argument", ex.message
  end

  # Create an instance of Boxen::Flags with optional `args`.

  def flags(*args)
    Boxen::Flags.new *args
  end
end
