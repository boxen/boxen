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
    rescue Octokit::Unauthorized => e
      puts
      if e.message =~ /OTP/
        if otp.nil?
          warn "It looks like you have two-factor auth enabled."
        else
          warn "That one time password didn't work. Let's try again."
        end
        get_otp
        get_tokens
      else
        abort "Sorry, I can't auth you on GitHub.",
          "Please check your credentials and teams and give it another try."
      end
    end
  end

  def run
    console = HighLine.new
    
    if ENV['PROMPT_GITHUB_LOGIN'] || ENV['PROMPT_GITHUB_PASSWORD']
      warn "Oh, looks like you've provided your username and password as environmental variables..."
      config.login = ENV['PROMPT_GITHUB_LOGIN']
      @password = ENV['PROMPT_GITHUB_PASSWORD']
    else
      warn "Hey, I need your current GitHub credentials to continue."

      config.login = console.ask "GitHub login: " do |q|
        q.default = config.login || config.user
        q.validate = /\A[^@]+\Z/
      end

      @password = console.ask "GitHub password: " do |q|
        q.echo = "*"
      end
    end
    
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
end
