require "boxen/test"
require "boxen/keychain"

class BoxenKeychainTest < Boxen::Test
  def setup
    @keychain = Boxen::Keychain.new('test') if osx?
  end

  def osx?
    RUBY_PLATFORM.downcase.include?("darwin")
  end

  def test_get_token
    return skip("Keychain helper is OSX only") unless osx?
    @keychain.expects(:get).with('GitHub API Token').returns('foobar')
    assert_equal 'foobar', @keychain.token
  end

  def test_set_token
    return skip("Keychain helper is OSX only") unless osx?
    @keychain.expects(:set).with('GitHub API Token', 'foobar').returns('foobar')
    assert_equal 'foobar', @keychain.token=('foobar')
  end
end
