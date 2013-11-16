require "boxen/preflight"
require "highline"
require "octokit"

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

    unless auth = tokens.detect { |a| a.note == "Boxen" }
      auth = tmp_api.create_authorization \
        :note => "Boxen",
        :scopes => %w(repo user),
        :headers => headers
    end

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
end
