require 'boxen/test'
require "boxen/util"
require 'boxen/keychain'

class BoxenKeychainTest < Boxen::Test
  def setup
    @keychain = Boxen::Keychain.new('test') if Boxen::Util.osx?
  end

  def test_get_token
    return skip('Keychain helper is OSX only') unless Boxen::Util.osx?
    @keychain.expects(:get).with('GitHub API Token').returns('foobar')
    assert_equal 'foobar', @keychain.token
  end

  def test_set_token
    return skip('Keychain helper is OSX only') unless Boxen::Util.osx?
    @keychain.expects(:set).with('GitHub API Token', 'foobar').returns('foobar')
    assert_equal 'foobar', @keychain.token=('foobar')
  end
end
