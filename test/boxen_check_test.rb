require "boxen/test"
require "boxen/check"

class BoxenCheckTest < Boxen::Test
  def test_initialize
    check = Boxen::Check.new :config
    assert_equal :config, check.config
  end

  def test_ok?
    ex = assert_raises RuntimeError do
      Boxen::Check.new(:config).ok?
    end

    assert_match "must implement", ex.message
  end

  def test_run
    ex = assert_raises RuntimeError do
      Boxen::Check.new(:config).run
    end

    assert_match "must implement", ex.message
  end

  def test_self_checks
    subclass = Class.new Boxen::Check
    Boxen::Check.const_set :TestCheck, subclass

    assert Boxen::Check.checks(:config).any? { |c| subclass === c },
      "an instance of TestCheck exists in checks"
  end

  def test_self_checks_subclasses
    klass = Struct.new :config
    Boxen::Check.const_set :TestBadCheck, klass

    refute Boxen::Check.checks(:config).any? { |c| klass === c },
      "checks are subclasses of Boxen::Check"
  end

  def test_self_run
    willrun = mock do
      expects(:ok?).returns false
      expects(:run)
    end

    wontrun = mock do
      expects(:ok?).returns true
    end

    Boxen::Check.expects(:checks).with(:config).returns [willrun, wontrun]
    Boxen::Check.run :config
  end
end
