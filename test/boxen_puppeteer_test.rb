require "boxen/test"
require "boxen/puppeteer"

class BoxenPuppeteerTest < Boxen::Test
  def test_initialize
    puppet = Boxen::Puppeteer.new :config
    assert_equal :config, puppet.config
  end

  def test_flags
    config = stub do
      stubs(:homedir).returns "homedir"
      stubs(:logfile).returns "logfile"
      stubs(:profile?).returns true
      stubs(:future_parser?).returns true
      stubs(:puppetdir).returns "puppetdir"
      stubs(:repodir).returns "repodir"
      stubs(:debug?).returns true
      stubs(:pretend?).returns true
      stubs(:report?).returns false
      stubs(:graph?).returns false
      stubs(:color?).returns false
    end

    puppet = Boxen::Puppeteer.new config
    flags  = puppet.flags

    assert_flag "--debug", flags
    assert_flag "--detailed-exitcodes", flags
    assert_flag "--evaltrace", flags
    assert_flag "--no-report", flags
    assert_flag "--noop", flags
    assert_flag "--summarize", flags
    assert_flag "--color=false", flags
    assert_flag "--parser=future", flags

    assert_flag_value "--confdir", :anything, flags
    assert_flag_value "--group", "admin", flags
    assert_flag_value "--vardir", :anything, flags
    assert_flag_value "--libdir", :anything, flags
    assert_flag_value "--manifestdir", :anything, flags
    assert_flag_value "--modulepath", :anything, flags

    assert_flag_value "--hiera_config", "/dev/null", flags

    assert_flag_value "--logdest", "logfile", flags
    assert_flag_value "--logdest", "console", flags
  end

  def test_run
    config = stub do
      stubs(:debug?).returns false
      stubs(:homedir).returns "homedir"
      stubs(:logfile).returns "logfile"
      stubs(:pretend?).returns false
      stubs(:profile?).returns false
      stubs(:future_parser?).returns false
      stubs(:report?).returns false
      stubs(:graph?).returns false
      stubs(:puppetdir).returns "puppetdir"
      stubs(:repodir).returns "test/fixtures/repo"
      stubs(:color?).returns true
    end

    puppet = Boxen::Puppeteer.new config

    FileUtils.expects(:rm_f).with config.logfile
    FileUtils.expects(:touch).with config.logfile
    FileUtils.expects(:mkdir_p).with File.dirname(config.logfile)
    FileUtils.expects(:mkdir_p).with config.puppetdir
    Boxen::Util.expects(:sudo).with *puppet.command

    puppet.run
  end

  def assert_flag(flag, flags)
    assert flags.include?(flag), "Flags must include #{flag}."
  end

  def assert_flag_value(flag, value, flags)
    pair = [flag, value]

    found = (0..flags.size).detect do |i|
      candidate = flags[i, pair.size]
      value == :anything ? candidate.size == pair.size : candidate == pair
    end

    assert found, "Flags must include #{flag} #{value}."
  end

  def test_status
    status = Boxen::Puppeteer::Status.new(0)
    assert status.success?

    status = Boxen::Puppeteer::Status.new(2)
    assert status.success?

    status = Boxen::Puppeteer::Status.new(1)
    refute status.success?
  end
end
