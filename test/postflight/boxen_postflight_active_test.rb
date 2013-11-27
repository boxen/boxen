require "boxen/test"
require "boxen/postflight"

class BoxenPostflightActiveTest < Boxen::Test
  def setup
    @check = Boxen::Postflight::Active.new :config
  end

  def test_ok?
    Boxen::Util.expects(:active?).returns true
    assert @check.ok?
  end

  def test_ok_bad
    Boxen::Util.expects(:active?).returns false
    refute @check.ok?
  end

  def test_run
    config = stub :envfile => "foo"
    @check = Boxen::Postflight::Active.new config

    stdout, stderr = capture_io do
      @check.run
    end

    assert_match "loaded", stderr
  end
end
