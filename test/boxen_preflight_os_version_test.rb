require 'boxen/test'
require 'boxen/preflight/os'

# Trigger rebuild

class BoxenPreflightOSTest < Boxen::Test
  def preflight
    @preflight ||= Boxen::Preflight::OS.new(mock('config'))
  end

  def test_invalid_version
    preflight.instance_variable_set(:@current_release, '10.7.0')

    assert !preflight.ok?
  end

  def test_valid_version
    preflight.instance_variable_set(:@current_release, '10.8.0')

    assert preflight.ok?
  end

  def test_valid_subversion
    preflight.instance_variable_set(:@current_release, '10.10.10')

    assert preflight.ok?
  end
end
