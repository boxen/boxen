require "boxen/test"
require "boxen"

class BoxenTest < Boxen::Test
  def test_self_active?
    ENV.expects(:include?).with("BOXEN_HOME").returns true
    assert Boxen.active?
  end

  def test_self_active_disabled
    ENV.expects(:include?).with("BOXEN_HOME").returns false
    refute Boxen.active?
  end

  def test_self_sudo
    Boxen.expects(:system).with "sudo", "-p", "Password for sudo: ", "echo", "foo"
    Boxen.sudo "echo", "foo"
  end
end
