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
  end

  HookYes = Struct.new(:config, :checkout, :result)
  HookNo  = Struct.new(:config, :checkout, :result)
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

  def test_specify_project
    skip "busted and probably due to be replaced if @jbarnette can fix it"
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
