require 'boxen/test'
require 'boxen/postflight'
require 'boxen/postflight/web_hook'

class Boxen::Config
  attr_writer :api
end

class BoxenPostflightWebHookTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new
    @checkout = Boxen::Checkout.new(@config)
    @command  = stub 'command', :success? => true
    @hook = Boxen::Postflight::WebHook.new @config, @command
    @hook.checkout = @checkout
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

  def test_ok
    @hook.stubs(:enabled?).returns(false)
    assert @hook.ok?

    @hook.stubs(:enabled?).returns(true)
    refute @hook.ok?
  end

  def test_run
    @config.stubs(:user).returns('fred')
    @checkout.stubs(:sha).returns('87dbag3')
    @command.stubs(:success?).returns(false)
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
