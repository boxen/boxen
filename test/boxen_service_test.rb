require "boxen/test"
require "boxen/service"

class BoxenServiceTest < Boxen::Test
  def test_list
    Dir.expects(:[]).with("/Library/LaunchDaemons/dev.*.plist").returns([
      "/Library/LaunchDaemons/dev.test.plist",
      "/Library/LaunchDaemons/dev.other.plist"
    ])

    services = Boxen::Service.list
    assert_equal ['other', 'test'], services.collect(&:name).sort
  end

  def test_list_enabled
    Boxen::Service.expects(:capture_output).with("sudo /bin/launchctl list").returns "foo bar dev.baz\nfoo bar bazz"
    services = Boxen::Service.list_enabled
    assert_equal ['baz'], services.collect(&:name)
  end

  def test_enable
    service = Boxen::Service.new('blip')
    Boxen::Util.expects(:sudo).with('/bin/launchctl', 'load', '-w',
      '/Library/LaunchDaemons/dev.blip.plist')
    service.enable
  end

  def test_disable
    service = Boxen::Service.new('thing')
    Boxen::Util.expects(:sudo).with('/bin/launchctl', 'unload', '-w',
      '/Library/LaunchDaemons/dev.thing.plist')
    service.disable
  end

  def test_to_s
    service = Boxen::Service.new('blam')
    assert_equal service.name, service.to_s
  end
end
