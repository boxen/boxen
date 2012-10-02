require "boxen/test"
require "boxen/puppeteer"

class BoxenPuppeteerTest < Boxen::Test
  def test_initialize
    puppet = Boxen::Puppeteer.new :config
    assert_equal :config, puppet.config
  end

  def test_flags
    config = stub do
      stubs(:logfile).returns "logfile"
      stubs(:profile?).returns true
      stubs(:debug?).returns true
      stubs(:pretend?).returns true
    end

    puppet = Boxen::Puppeteer.new config
    flags  = puppet.flags

    assert_flag "--debug", flags
    assert_flag "--detailed-exitcodes", flags
    assert_flag "--evaltrace", flags
    assert_flag "--no-report", flags
    assert_flag "--noop", flags
    assert_flag "--summarize", flags

    assert_flag_value "--confdir", :anything, flags
    assert_flag_value "--vardir", :anything, flags
    assert_flag_value "--libdir", :anything, flags
    assert_flag_value "--manifestdir", :anything, flags
    assert_flag_value "--modulepath", :anything, flags

    assert_flag_value "--logdest", "logfile", flags
    assert_flag_value "--logdest", "console", flags
  end

  def test_run
    config = stub do
      stubs(:debug?).returns false
      stubs(:logfile).returns "logfile"
      stubs(:pretend?).returns false
      stubs(:profile?).returns false
      stubs(:repodir).returns "test/fixtures/repo"
    end

    puppet = Boxen::Puppeteer.new config

    Boxen::Util.expects(:sudo).with "/bin/rm", "-f", "logfile"
    Boxen::Util.expects(:sudo).with "/bin/mkdir", "-p", "/tmp/puppet"
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
end
