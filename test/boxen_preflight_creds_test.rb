require 'boxen/test'
require 'boxen/config'
require 'boxen/preflight/creds'

class BoxenPreflightCredsTest < Boxen::Test
  # Make a struct to use for stubbing out authorization objects.
  Struct.new("Authorization", :id, :note, :fingerprint, :token)

  def setup
    @config   = Boxen::Config.new do |c|
      c.user  = 'mojombo'
      c.token = 'sekr3t!'
    end
    ENV.delete("BOXEN_GITHUB_LOGIN")
    ENV.delete("BOXEN_GITHUB_PASSWORD")
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

    error = Octokit::OneTimePasswordRequired.new
    error.stubs(:message).returns("OTP")

    preflight.tmp_api.expects(:authorizations).with(blank_opt).raises(error)
    preflight.tmp_api.expects(:authorizations).with(good_otp).returns([])
    preflight.tmp_api.expects(:create_authorization).raises(error)

    preflight.expects(:warn)
    HighLine.any_instance.expects(:ask).returns("123456")

    preflight.get_tokens
    assert_equal "123456", preflight.otp
  end

  def test_fetch_login_and_password_when_nothing_is_given_in_env
    # fetches login and password by asking
    preflight = Boxen::Preflight::Creds.new @config
    HighLine.any_instance.expects(:ask).with("GitHub login: ").returns "l"
    HighLine.any_instance.expects(:ask).with("GitHub password: ").returns "p"
    preflight.send(:fetch_login_and_password)

    assert_equal "l", @config.login
    assert_equal "p", preflight.instance_variable_get(:@password)
  end

  def test_fetch_password_when_login_is_given_in_env
    # fetches only password by asking
    ENV["BOXEN_GITHUB_LOGIN"] = "l"
    preflight = Boxen::Preflight::Creds.new @config
    preflight.expects(:warn)
    HighLine.any_instance.expects(:ask).with("GitHub login: ").never
    HighLine.any_instance.expects(:ask).with("GitHub password: ").returns "p"
    preflight.send(:fetch_login_and_password)

    assert_equal "l", @config.login
    assert_equal "p", preflight.instance_variable_get(:@password)
  end

  def test_fetch_login_when_password_is_given_in_env
    # fetches only login by asking
    ENV["BOXEN_GITHUB_PASSWORD"] = "p"
    preflight = Boxen::Preflight::Creds.new @config
    preflight.expects(:warn)
    HighLine.any_instance.expects(:ask).with("GitHub login: ").returns "l"
    HighLine.any_instance.expects(:ask).with("GitHub password: ").never
    preflight.send(:fetch_login_and_password)

    assert_equal "l", @config.login
    assert_equal "p", preflight.instance_variable_get(:@password)
  end

  def test_run_with_existing_token
    preflight = Boxen::Preflight::Creds.new @config
    note = "App1"
    fingerprint = "Fingerprint1"
    existing_token = Struct::Authorization.new(1, note, fingerprint, "Token1")

    preflight.stubs(:fetch_login_and_password).returns("")
    preflight.stubs(:get_tokens).returns([existing_token])
    preflight.stubs(:note).returns(note)
    preflight.stubs(:fingerprint).returns(fingerprint)
    preflight.stubs(:ok?).returns(true)
    preflight.tmp_api.expects(:delete_authorization).with(existing_token.id, :headers => {})
    preflight.tmp_api.expects(:create_authorization).with(
      :note => note,
      :fingerprint => fingerprint,
      :scopes => %w(repo user),
      :headers => {}
    ).returns(existing_token)

    preflight.run
  end

  def test_run_with_no_existing_token
    preflight = Boxen::Preflight::Creds.new @config
    note = "App1"
    fingerprint = "Fingerprint1"
    new_token = Struct::Authorization.new(1, note, fingerprint, "Token1")

    preflight.stubs(:fetch_login_and_password).returns("")
    preflight.stubs(:get_tokens).returns([])
    preflight.stubs(:note).returns(note)
    preflight.stubs(:fingerprint).returns(fingerprint)
    preflight.stubs(:ok?).returns(true)
    preflight.tmp_api.expects(:delete_authorization).never
    preflight.tmp_api.expects(:create_authorization).with(
      :note => note,
      :fingerprint => fingerprint,
      :scopes => %w(repo user),
      :headers => {}
    ).returns(new_token)

    preflight.run
  end

  def test_run_does_not_delete_unrelated_tokens
    preflight = Boxen::Preflight::Creds.new @config
    note = "App1"
    fingerprint = "Fingerprint1"
    new_token = Struct::Authorization.new(1, note, fingerprint, "Token1")
    unrelated_token = Struct::Authorization.new(2, "App2", fingerprint, "Token2")
    unrelated_token_with_fingerprint = Struct::Authorization.new(3, "App3", "Fingerprint3", "Token3")

    preflight.stubs(:fetch_login_and_password).returns("")
    preflight.stubs(:get_tokens).returns(
      [unrelated_token, unrelated_token_with_fingerprint]
    )
    preflight.stubs(:note).returns(note)
    preflight.stubs(:fingerprint).returns(fingerprint)
    preflight.stubs(:ok?).returns(true)
    preflight.tmp_api.expects(:delete_authorization).never
    preflight.tmp_api.expects(:create_authorization).with(
      :note => note,
      :fingerprint => fingerprint,
      :scopes => %w(repo user),
      :headers => {}
    ).returns(new_token)

    preflight.run
  end

  def test_run_does_delete_legacy_token
    preflight = Boxen::Preflight::Creds.new @config
    note = "App1"
    fingerprint = "Fingerprint1"
    existing_token = Struct::Authorization.new(1, note, fingerprint, "Token1")
    legacy_token = Struct::Authorization.new(2, "Boxen", nil, "Token2")

    preflight.stubs(:fetch_login_and_password).returns("")
    preflight.stubs(:get_tokens).returns([existing_token, legacy_token])
    preflight.stubs(:note).returns(note)
    preflight.stubs(:fingerprint).returns(fingerprint)
    preflight.stubs(:ok?).returns(true)
    preflight.tmp_api.expects(:delete_authorization).with(2, :headers => {})
    preflight.tmp_api.expects(:delete_authorization).with(1, :headers => {})
    preflight.tmp_api.expects(:create_authorization).with(
      :note => note,
      :fingerprint => fingerprint,
      :scopes => %w(repo user),
      :headers => {}
    ).returns(existing_token)

    preflight.run
  end
end
