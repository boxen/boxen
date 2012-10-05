require "boxen/test"
require "boxen/cli"

class BoxenCLITest < Boxen::Test
  def setup
    @config = Boxen::Config.new
    @flags  = Boxen::Flags.new
    @cli = Boxen::CLI.new(@config, @flags)
  end

  def test_initialize
    config = Boxen::Config.new
    flags  = Boxen::Flags.new

    cli = Boxen::CLI.new config, flags

    assert_equal config, cli.config
    assert_equal flags, cli.flags
    assert_equal config, cli.puppet.config
    
    assert_equal config, cli.report.config
    assert_equal config, cli.report.checkout.config
    assert_equal cli.checkout, cli.report.checkout
    assert_equal cli.puppet, cli.report.puppet
  end

  def test_report_failure
    @cli.stubs(:exec)
    @cli.stubs(:abort)
    @cli.stubs(:warn)

    @cli.puppet.stubs(:run).returns(1)
    @cli.report.expects(:record_failure)
    @cli.report.expects(:close_failures).never

    @cli.run
  end

  def test_run_success
    @cli.stubs(:exec)
    @cli.stubs(:abort)

    @cli.puppet.stubs(:run).returns(0)
    @cli.report.expects(:record_failure).never
    @cli.report.expects(:close_failures)

    @cli.run
  end
end
