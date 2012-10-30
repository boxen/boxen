require "boxen/test"
require "boxen/runner"

class BoxenRunnerTest < Boxen::Test
  def setup
    @config = Boxen::Config.new
    @flags  = Boxen::Flags.new
    @runner = Boxen::Runner.new(@config, @flags)

    $stdout.stubs(:puts).returns(true)
    $stdout.stubs(:write).returns(true)
  end

  def test_initialize
    config = Boxen::Config.new
    flags  = Boxen::Flags.new

    runner = Boxen::Runner.new(config, flags)

    assert_equal config, runner.config
    assert_equal flags,  runner.flags
    assert_equal config, runner.puppet.config

    assert_equal config,          runner.reporter.config
    assert_equal config,          runner.reporter.checkout.config
    assert_equal runner.checkout, runner.reporter.checkout
    assert_equal runner.puppet,   runner.reporter.puppet
  end

  def test_issues?
    @config.stealth = true
    @config.pretend = true
    @runner.checkout.stubs(:master?).returns(false)
    assert !@runner.issues?

    @config.stealth = false
    @config.pretend = true
    @runner.checkout.stubs(:master?).returns(false)
    assert !@runner.issues?

    @config.stealth = true
    @config.pretend = false
    @runner.checkout.stubs(:master?).returns(false)
    assert !@runner.issues?

    @config.stealth = true
    @config.pretend = true
    @runner.checkout.stubs(:master?).returns(true)
    assert !@runner.issues?

    @config.stealth = false
    @config.pretend = true
    @runner.checkout.stubs(:master?).returns(true)
    assert !@runner.issues?

    @config.stealth = true
    @config.pretend = false
    @runner.checkout.stubs(:master?).returns(true)
    assert !@runner.issues?

    @config.stealth = false
    @config.pretend = false
    @runner.checkout.stubs(:master?).returns(true)
    assert @runner.issues?
  end

  def test_report_failure
    @runner.stubs(:issues?).returns(true)
    status = stub('status', :success? => false)
    @runner.stubs(:process).returns(status)
    @runner.stubs(:warn)

    @runner.reporter.expects(:record_failure)
    @runner.reporter.expects(:close_failures).never

    @runner.run
  end

  def test_run_success
    @runner.stubs(:issues?).returns(true)
    status = stub('status', :success? => true)
    @runner.stubs(:process).returns(status)

    @runner.reporter.expects(:record_failure).never
    @runner.reporter.expects(:close_failures)

    @runner.run
  end

  def test_run_failure_no_issues
    @runner.stubs(:issues?).returns(false)
    status = stub('status', :success? => false)
    @runner.stubs(:process).returns(status)

    @runner.reporter.expects(:record_failure).never
    @runner.reporter.expects(:close_failures).never

    @runner.run
  end

  def test_run_success_no_issues
    @runner.stubs(:issues?).returns(false)
    status = stub('status', :success? => true)
    @runner.stubs(:process).returns(status)

    @runner.reporter.expects(:record_failure).never
    @runner.reporter.expects(:close_failures).never

    @runner.run
  end

  def test_disable_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--disable-services')
    runner = Boxen::Runner.new config, flags

    services = Array.new(3) { mock('service', :disable => true) }
    Boxen::Service.stubs(:list).returns(services)

    assert_raises(SystemExit) do
      runner.process
    end
  end

  def test_enable_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--enable-services')
    runner = Boxen::Runner.new config, flags

    services = Array.new(3) { mock('service', :enable => true) }
    Boxen::Service.stubs(:list).returns(services)

    assert_raises(SystemExit) do
      runner.process
    end
  end

  def test_list_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--list-services')
    runner = Boxen::Runner.new config, flags

    Boxen::Service.expects(:list).returns(%w[a list of services])

    assert_raises(SystemExit) do
      runner.process
    end
  end

  def test_specify_project
    fact = 'cli_boxen_projects'
    refute Facter.value(fact)

    project = 'some_project'
    flags   = Boxen::Flags.new(project)

    runner = Boxen::Runner.new(@config, flags)
    runner.process
    assert_equal project, Facter.value(fact)


    project = 'other_project'
    flags   = Boxen::Flags.new('--debug', project)

    runner = Boxen::Runner.new(@config, flags)
    runner.process
    assert_equal project, Facter.value(fact)


    projects = %w[my cool projects]
    flags    = Boxen::Flags.new('--noop', *projects)

    runner = Boxen::Runner.new(@config, flags)
    runner.process
    assert_equal projects.join(','), Facter.value(fact)
  end
end
