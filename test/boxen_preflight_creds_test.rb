require 'boxen/test'
require 'boxen/preflight/creds'

class BoxenPreflightCredsTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new do |c|
      c.user = 'mojombo'
      c.password = 'sekr3t!'
    end
  end

  def test_basic
    preflight = Boxen::Preflight::Creds.new @config

    error = Octokit::Unauthorized.new
    @config.api.stubs(:user).raises(error)

    refute preflight.basic?
  end

  def test_basic_with_otp_challenge
    preflight = Boxen::Preflight::Creds.new @config

    error = Octokit::Unauthorized.new
    error.stubs(:message).returns("OTP")
    @config.stubs(:create_authorization).raises(error)

    preflight.expects(:warn)
    HighLine.any_instance.expects(:ask).returns("123456")

    otp_options = {:headers => {"X-GitHub-OTP" => "123456"}}

    @config.api.expects(:user).with(otp_options)

    preflight.basic_with_otp?
    assert_equal "123456", preflight.otp
  end

end
