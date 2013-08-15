require 'boxen/test'
require 'boxen/preflight/creds'

class BoxenPreflightCredsTest < Boxen::Test
  def setup
    @config   = Boxen::Config.new do |c|
      c.user  = 'mojombo'
      c.token = 'sekr3t!'
    end
  end

  def test_basic
    preflight = Boxen::Preflight::Creds.new @config

    error = Octokit::Unauthorized.new
    @config.api.stubs(:user).raises(error)

    refute preflight.ok?
  end

  def test_basic_with_otp_challenge
    preflight = Boxen::Preflight::Creds.new @config

    blank_opt = {:headers => {}}
    good_otp  = {:headers => {"X-GitHub-OTP" => "123456"}}

    error = Octokit::Unauthorized.new
    error.stubs(:message).returns("OTP")

    preflight.tmp_api.expects(:authorizations).with(blank_opt).raises(error)
    preflight.tmp_api.expects(:authorizations).with(good_otp).returns([])
    preflight.tmp_api.expects(:create_authorization).raises(error)

    preflight.expects(:warn)
    HighLine.any_instance.expects(:ask).returns("123456")

    preflight.get_tokens
    assert_equal "123456", preflight.otp
  end

end
