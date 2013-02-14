require "boxen/test"
require "boxen/keychain"

class BoxenKeychainTest < Boxen::Test
  def setup
    @keychain = Boxen::Keychain.new('test')
  end

  def test_true
    assert true
  end
end