require "boxen/test"
require "boxen/hook/web"

class Boxen::Config
  attr_writer :api
end

class BoxenHookWebTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new
    @checkout = Boxen::Checkout.new(@config)
    @puppet   = mock 'puppeteer'
    @result   = stub 'result', :success? => true
    @hook = Boxen::Hook::Web.new @config, @checkout, @puppet, @result
  end

  def test_enabled
    original = ENV['BOXEN_WEB_HOOK_URL']

    ENV['BOXEN_WEB_HOOK_URL'] = nil
    refute @hook.enabled?

    ENV['BOXEN_WEB_HOOK_URL'] = ''
    refute @hook.enabled?

    ENV['BOXEN_WEB_HOOK_URL'] = '1'
    assert @hook.enabled?

    ENV['BOXEN_WEB_HOOK_URL'] = original
  end

  def test_perform
    @hook.stubs(:enabled?).returns(false)
    refute @hook.perform?

    @hook.stubs(:enabled?).returns(true)
    assert @hook.perform?
  end

  def test_run
    @config.stubs(:user).returns('fred')
    @checkout.stubs(:sha).returns('87dbag3')
    @result.stubs(:success?).returns(false)
    now = Time.now
    Time.stubs(:now).returns(now)

    @hook.stubs(:enabled?).returns(true)

    @hook.expects(:post_web_hook).with({
      :login  => 'fred',
      :sha    => '87dbag3',
      :status => 'failure',
      :time   => "#{now.utc.to_i}"
    })

    @hook.run
  end
end