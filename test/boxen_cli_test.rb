require "boxen/test"
require "boxen/cli"

class BoxenCLITest < Boxen::Test
  def setup
    @config = Boxen::Config.new
    @flags  = Boxen::Flags.new
    @cli = Boxen::CLI.new(@config, @flags)

    $stdout.stubs(:puts).returns(true)
    $stdout.stubs(:write).returns(true)
  end

  def test_initialize
    config = Boxen::Config.new
    flags  = Boxen::Flags.new

    cli = Boxen::CLI.new config, flags

    assert_equal config, cli.config
    assert_equal flags, cli.flags
    assert_equal config, cli.puppet.config

    assert_equal config, cli.reporter.config
    assert_equal config, cli.reporter.checkout.config
    assert_equal cli.checkout, cli.reporter.checkout
    assert_equal cli.puppet, cli.reporter.puppet
  end

  def test_issues?
    @config.stealth = true
    @config.pretend = true
    @cli.checkout.stubs(:master?).returns(false)
    assert !@cli.issues?

    @config.stealth = false
    @config.pretend = true
    @cli.checkout.stubs(:master?).returns(false)
    assert !@cli.issues?

    @config.stealth = true
    @config.pretend = false
    @cli.checkout.stubs(:master?).returns(false)
    assert !@cli.issues?

    @config.stealth = true
    @config.pretend = true
    @cli.checkout.stubs(:master?).returns(true)
    assert !@cli.issues?

    @config.stealth = false
    @config.pretend = true
    @cli.checkout.stubs(:master?).returns(true)
    assert !@cli.issues?

    @config.stealth = true
    @config.pretend = false
    @cli.checkout.stubs(:master?).returns(true)
    assert !@cli.issues?

    @config.stealth = false
    @config.pretend = false
    @cli.checkout.stubs(:master?).returns(true)
    assert @cli.issues?
  end

  def test_report_failure
    @cli.stubs(:issues?).returns(true)
    @cli.stubs(:process).returns(1)
    @cli.stubs(:warn)

    @cli.reporter.expects(:record_failure)
    @cli.reporter.expects(:close_failures).never

    @cli.run
  end

  def test_run_success
    @cli.stubs(:issues?).returns(true)
    @cli.stubs(:process).returns(0)

    @cli.reporter.expects(:record_failure).never
    @cli.reporter.expects(:close_failures)

    @cli.run
  end

  def test_run_success_exit_code_2
    @cli.stubs(:issues?).returns(true)
    @cli.stubs(:process).returns(2)

    @cli.reporter.expects(:record_failure).never
    @cli.reporter.expects(:close_failures)

    @cli.run
  end

  def test_run_failure_no_issues
    @cli.stubs(:issues?).returns(false)
    @cli.stubs(:process).returns(1)

    @cli.reporter.expects(:record_failure).never
    @cli.reporter.expects(:close_failures).never

    @cli.run
  end

  def test_run_success_no_issues
    @cli.stubs(:issues?).returns(false)
    @cli.stubs(:process).returns(0)

    @cli.reporter.expects(:record_failure).never
    @cli.reporter.expects(:close_failures).never

    @cli.run
  end

  def test_run_success_exit_code_2_no_issues
    @cli.stubs(:issues?).returns(false)
    @cli.stubs(:process).returns(2)

    @cli.reporter.expects(:record_failure).never
    @cli.reporter.expects(:close_failures).never

    @cli.run
  end

  def test_disable_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--disable-services')
    cli    = Boxen::CLI.new config, flags

    Dir.expects(:[]).with("/Library/LaunchDaemons/com.boxen.*.plist").returns([
      "/Library/LaunchDaemons/com.boxen.test.plist"
    ])
    Boxen::Util.expects(:sudo).with(
      "/bin/launchctl",
      "unload",
      "-w",
      "/Library/LaunchDaemons/com.boxen.test.plist"
    ).returns(true)

    assert_raises(SystemExit) do
      cli.process
    end

    def test_enable_services
      config = Boxen::Config.new
      flags  = Boxen::Flags.new('--enable-services')
      cli    = Boxen::CLI.new config, flags

      Dir.expects(:[]).with("/Library/LaunchDaemons/com.boxen.*.plist").returns([
        "/Library/LaunchDaemons/com.boxen.test.plist"
      ])

      Boxen::Util.expects(:sudo).with(
        "/bin/launchctl",
        "load",
        "-w",
        "/Library/LaunchDaemons/com.boxen.test.plist"
      ).returns(true)

      assert_raises(SystemExit) do
        cli.process
      end

      def test_list_services
        config = Boxen::Config.new
        flags  = Boxen::Flags.new('--list-services')
        cli    = Boxen::CLI.new config, flags

        Dir.expects(:[]).with("/Library/LaunchDaemons/com.boxen.*.plist").returns([
          "/Library/LaunchDaemons/com.boxen.test.plist"
        ])

        assert_raises(SystemExit) do
          cli.process
        end
      end
    end
  end
end