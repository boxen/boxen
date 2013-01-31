require "boxen/preflight"
require "highline"
require "octokit"

# HACK: Unless this is `false`, HighLine has some really bizarre
# problems with empty/expended streams at bizarre intervals.

HighLine.track_eof = false

class Boxen::Preflight::Creds < Boxen::Preflight
  def basic?
    config.api.user rescue nil
  end

  def ok?
    basic? && token?
  end

  def token?
    return unless config.token

    tapi = Octokit::Client.new \
      :login => config.login, :oauth_token => config.token

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

    unless auth = config.api.authorizations.detect { |a| a.note == "Boxen" }
      auth = config.api.create_authorization \
        :note => "Boxen", :scopes => %w(repo user)
    end

    # Reset the token for later.

    config.token = auth.token
  end
end
