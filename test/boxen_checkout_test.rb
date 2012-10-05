require "boxen/test"
require "boxen/checkout"

class BoxenCheckoutTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new { |c|  c.repodir = 'test/fixtures/repo' }
    @checkout = Boxen::Checkout.new @config
  end

  def test_initialize
    checkout = Boxen::Checkout.new :config
    assert_equal :config, checkout.config
  end

  def test_sha
    sha = 'deadbeef'
    @checkout.expects(:"`").with("git rev-parse HEAD").returns("#{sha}\n")
    assert_equal sha, @checkout.sha
  end

  def test_master?
    @checkout.stubs(:"`").with("git symbolic-ref HEAD").returns("refs/heads/topic\n")
    assert !@checkout.master?

    @checkout.stubs(:"`").with("git symbolic-ref HEAD").returns("refs/heads/master\n")
    assert @checkout.master?
  end

  def test_changes
    changes = '   maybe a bunch of stuff happened   '
    @checkout.expects(:"`").with("git status --porcelain").returns(changes)
    assert_equal changes.strip, @checkout.changes
  end

  def test_dirty?
    @checkout.stubs(:changes).returns('stuff happened')
    assert @checkout.dirty?

    @checkout.stubs(:changes).returns('')
    assert !@checkout.dirty?
  end
end
