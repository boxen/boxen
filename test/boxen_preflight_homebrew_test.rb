require 'boxen/test'
require 'boxen/preflight/homebrew'

class BoxenPreflightHomebrewTest < Boxen::Test
  def test_directory_check
    preflight = Boxen::Preflight::Homebrew.new(mock('config'))
    File.expects(:exist?).with("/usr/local/Library/Homebrew").returns(false)
    assert preflight.ok?
  end
end
