require "boxen/preflight"
require "highline"
require "octokit"

# HACK: Unless this is `false`, HighLine has some really bizarre
# problems with empty/expended streams at bizarre intervals.

HighLine.track_eof = false

class Boxen::Preflight::Creds < Boxen::Preflight

  attr :otp

  def basic?
    begin
      config.api.user
    rescue Octokit::Unauthorized => e
      basic_with_otp? if e.message =~ /OTP/
    end
  end

  def basic_with_otp?
    console = HighLine.new

    # junk API call to send OTP until we implement PUT
    config.api.create_authorization rescue nil

    warn "It looks like you have two-factor auth enabled."
    puts
    @otp = console.ask "One time password (via SMS or device):" do |q|
      q.echo = '*'
    end

    config.api.user(:headers => {"X-GitHub-OTP" => otp}) rescue nil
  end

  def ok?
    basic? && token?
  end

  def token?
    return unless config.token

    tapi = Octokit::Client.new :oauth_token => config.token

    tapi.user rescue nil
  end

  def run
    console = HighLine.new

    warn "Hey, I need your current GitHub credentials to continue."

    config.login = console.ask "GitHub login: " do |q|
      q.default = config.login || config.user
      q.validate = /\A[^@]+\Z/
    end

    config.password = console.ask "GitHub password: " do |q|
      q.echo = "*"
    end

    unless basic?
      puts # i <3 vertical whitespace

      abort "Sorry, I can't auth you on GitHub.",
        "Please check your credentials and teams and give it another try."
    end

    # Okay, the basic creds are good, let's deal with an OAuth token.

    headers = {}
    headers["X-GitHub-OTP"] = otp unless otp.nil?

    tokens = config.api.authorizations(:headers => headers)
    unless auth = tokens.detect { |a| a.note == "Boxen" }
      auth = config.api.create_authorization \
        :note => "Boxen",
        :scopes => %w(repo user),
        :headers => headers
    end

    # Reset the token for later.

    config.token = auth.token
  end
end
