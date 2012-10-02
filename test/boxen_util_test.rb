require "boxen/test"
require "boxen/util"

class BoxenUtilTest < Boxen::Test
  def test_self_active?
    ENV.expects(:include?).with("BOXEN_HOME").returns true
    assert Boxen::Util.active?
  end

  def test_self_active_disabled
    ENV.expects(:include?).with("BOXEN_HOME").returns false
    refute Boxen::Util.active?
  end

  def test_self_sudo
    Boxen::Util.expects(:system).
      with "sudo", "-p", "Password for sudo: ", "echo", "foo"

    Boxen::Util.sudo "echo", "foo"
  end
end
