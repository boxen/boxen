require "boxen/preflight"
require "highline"
require "octokit"
require "digest"
require "socket"

# HACK: Unless this is `false`, HighLine has some really bizarre
# problems with empty/expended streams at bizarre intervals.

HighLine.track_eof = false

class Boxen::Preflight::Creds < Boxen::Preflight
  attr :otp
  attr :password

  def ok?
    if config.token && config.api.user
      # There was a period of time when login wasn't geting set on first run.
      # This should correct that.
      config.login = config.api.user.login
      true
    end
  rescue
    nil
  end

  def tmp_api
    @tmp_api ||= Octokit::Client.new :login => config.login, :password => password, :auto_paginate => true
  end

  def headers
    otp.nil? ? {} : {"X-GitHub-OTP" => otp}
  end

  def get_otp
    console = HighLine.new

    # junk API call to send OTP until we implement PUT
    tmp_api.create_authorization rescue nil

    @otp = console.ask "One time password (via SMS or device):" do |q|
      q.echo = '*'
    end
  end

  # Attempt to use the username+password to get a list of the user's OAuth
  # authorizations from the API. If it fails because of 2FA, ask the user for
  # her OTP and try again.
  #
  # Returns a list of authorizations
  def get_tokens
    begin
      tmp_api.authorizations(:headers => headers)
    rescue Octokit::Unauthorized
      abort "Sorry, I can't auth you on GitHub.",
        "Please check your credentials and teams and give it another try."
    rescue Octokit::OneTimePasswordRequired
      puts
      if otp.nil?
        warn "It looks like you have two-factor auth enabled."
      else
        warn "That one time password didn't work. Let's try again."
      end
      get_otp
      get_tokens
    end
  end

  def run
    fetch_login_and_password
    tokens = get_tokens

    # Boxen now supports the updated GitHub Authorizations API by using a unique
    # `fingerprint` for each Boxen installation for a user. We delete any older
    # authorization that does not make use of `fingerprint` so that the "legacy"
    # authorization doesn't persist in the user's list of personal access
    # tokens.
    legacy_auth = tokens.detect { |a| a.note == "Boxen" && a.fingerprint == nil }
    tmp_api.delete_authorization(legacy_auth.id, :headers => headers) if legacy_auth

    # The updated GitHub authorizations API, in order to improve security, no
    # longer returns a plaintext `token` for existing authorizations. So, if an
    # authorization already exists for this machine we need to first delete it
    # so that we can create a new one.
    auth = tokens.detect { |a| a.note == note && a.fingerprint == fingerprint }
    tmp_api.delete_authorization(auth.id, :headers => headers) if auth

    auth = tmp_api.create_authorization(
      :note => note,
      :scopes => %w(repo user),
      :fingerprint => fingerprint,
      :headers => headers
    )

    config.token = auth.token

    unless ok?
      puts
      abort "Something went terribly wrong.",
        "I was able to get your OAuth token, but was unable to use it."
    end
  end

  private

  def fetch_login_and_password
    console = HighLine.new

    config.login = fetch_from_env("login") || console.ask("GitHub login: ") do |q|
      q.default = config.login || config.user
      q.validate = /\A[^@]+\Z/
    end

    @password = fetch_from_env("password") || console.ask("GitHub password: ") do |q|
      q.echo = "*"
    end
  end

  def fetch_from_env(thing)
    key = "BOXEN_GITHUB_#{thing.upcase}"
    return unless found = ENV[key]
    warn "Oh, looks like you've provided your #{thing} as environmental variable..."
    found
  end

  def fingerprint
    @fingerprint ||= begin
      # See Apple technical note TN1103, "Uniquely Identifying a Macintosh
      # Computer."
      serial_number_match_data = IO.popen(
        ["ioreg", "-c", "IOPlatformExpertDevice", "-d", "2"]
      ).read.match(/"IOPlatformSerialNumber" = "([[:alnum:]]+)"/)
      if serial_number_match_data
        # The fingerprint must be unique across all personal access tokens for a
        # given user. We prefix the serial number with the application name to
        # differentiate between any other personal access token that uses the
        # Mac serial number for the fingerprint.
        Digest::SHA256.hexdigest("Boxen: #{serial_number_match_data[1]}")
      else
        abort "Sorry, I was unable to obtain your Mac's serial number.",
          "Boxen requires access to your Mac's serial number in order to generate a unique GitHub personal access token."
      end
    end
  end

  def note
    @note ||= "Boxen: #{Socket.gethostname}"
  end
end
