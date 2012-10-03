require 'boxen/test'
require 'boxen/preflight/etc_my_cnf'

class BoxenPreflightEtcMyCnfTest < Boxen::Test
  def test_file_check
    preflight = Boxen::Preflight::EtcMyCnf.new(mock('config'))
    File.expects(:file?).with("/etc/my.cnf").returns(false)
    assert preflight.ok?
  end
end
