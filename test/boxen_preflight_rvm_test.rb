require 'boxen/test'
require 'boxen/preflight/rvm'

class BoxenPreflightRVMTest < Boxen::Test
  def test_directory_check
    preflight = Boxen::Preflight::RVM.new(mock('config'))
    File.expects(:exist?).with("#{ENV['HOME']}/.rvm").returns(false)
    assert preflight.ok?
  end
end
