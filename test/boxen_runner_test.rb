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
  end

  HookYes = Struct.new(:config, :checkout, :puppet, :result)
  HookNo  = Struct.new(:config, :checkout, :puppet, :result)
  def test_report
    runner = Boxen::Runner.new(@config, @flags)
    runner.stubs(:hooks).returns([HookYes, HookNo])

    hook_yes = stub('HookYes')
    hook_no  = stub('HookNo')

    HookYes.stubs(:new).returns(hook_yes)
    HookNo.stubs(:new).returns(hook_no)

    hook_yes.expects(:run).once
    hook_no.expects(:run).once

    runner.report(stub('result'))
  end

  def test_disable_service
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--disable-service', 'test')
    runner = Boxen::Runner.new config, flags

    service = mock('service', :disable => true)
    Boxen::Service.stubs(:new).returns(service)

    assert_raises(SystemExit) do
      runner.process
    end
  end

  def test_enable_service
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--enable-service', 'test')
    runner = Boxen::Runner.new config, flags

    service = mock('service', :enable => true)
    Boxen::Service.stubs(:new).returns(service)

    assert_raises(SystemExit) do
      runner.process
    end
  end

  def test_restart_service
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--restart-service', 'test')
    runner = Boxen::Runner.new config, flags

    service = mock('service')
    service.expects(:disable).once
    service.expects(:enable).once

    Boxen::Service.stubs(:new).returns(service)

    assert_raises(SystemExit) do
      runner.process
    end
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

  def test_restart_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--restart-services')
    runner = Boxen::Runner.new config, flags

    services = Array.new(3) { mock('service') }
    services.each do |service|
      service.expects(:disable).once
      service.expects(:enable).once
    end
    Boxen::Service.stubs(:list_enabled).returns(services)

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
    skip "busted and probably due to be replaced if @jbarnette can fix it"
    fact = 'cli_boxen_projects'
    refute Facter.value(fact)

    project = 'some_project'
    flags   = Boxen::Flags.new(project)

    runner = Boxen::Runner.new(@config, flags)
    runner.puppet.expects(:run).with().returns(true)
    runner.process
    assert_equal project, Facter.value(fact)


    project = 'other_project'
    flags   = Boxen::Flags.new('--debug', project)

    runner = Boxen::Runner.new(@config, flags)
    runner.puppet.expects(:run).with().returns(true)
    runner.process
    assert_equal project, Facter.value(fact)


    projects = %w[my cool projects]
    flags    = Boxen::Flags.new('--noop', *projects)

    runner = Boxen::Runner.new(@config, flags)
    runner.puppet.expects(:run).with().returns(true)
    runner.process
    assert_equal projects.join(','), Facter.value(fact)
  end
end
