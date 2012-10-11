require "boxen/test"
require "boxen/service"

class BoxenServiceTest < Boxen::Test
  def test_list
    Dir.expects(:[]).with("/Library/LaunchDaemons/com.boxen.*.plist").returns([
      "/Library/LaunchDaemons/com.boxen.test.plist",
      "/Library/LaunchDaemons/com.boxen.other.plist"
    ])

    services = Boxen::Service.list
    assert_equal ['other', 'test'], services.collect(&:name).sort
  end

  def test_enable
    service = Boxen::Service.new('blip')
    Boxen::Util.expects(:sudo).with('/bin/launchctl', 'load', '-w',
      '/Library/LaunchDaemons/com.boxen.blip.plist')
    service.enable
  end

  def test_disable
    service = Boxen::Service.new('thing')
    Boxen::Util.expects(:sudo).with('/bin/launchctl', 'unload', '-w',
      '/Library/LaunchDaemons/com.boxen.thing.plist')
    service.disable
  end
end
