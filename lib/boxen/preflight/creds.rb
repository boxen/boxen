require "boxen/preflight"
require "highline"
require "octokit"

# HACK: Unless this is `false`, HighLine has some really bizarre
# problems with empty/expended streams at bizarre intervals.

HighLine.track_eof = false

class Boxen::Preflight::Creds < Boxen::Preflight
  def ok?
    token?
  end

  def token?
    return unless config.token
    config.api.user rescue nil
  end

  def token_from_password(password)
    tapi = Octokit::Client.new :login => config.login, :password => password
    auth = tapi.create_authorization :note => "Boxen", :scopes => %w(repo user)
    auth.token
  rescue
    nil
  end

  def looks_like_token?(token)
    token =~ /\A[a-zA-Z0-9]{40}\z/
  end

  def run
    console = HighLine.new

    warn "Hey, I need your current GitHub credentials to continue."

    config.login = console.ask "GitHub login: " do |q|
      q.default = config.login || config.user
      q.validate = /\A[^@]+\Z/
    end
  
    puts "You can use your password, or a Personal API Token which can be created here: https:///settings/applications"
    password_or_token = console.ask "GitHub Password or Persoanl Access Token: " do |q|
      q.echo = "*"
    end

    config.token = if looks_like_token?(password_or_token)
                     password_or_token
                   else
                     token_from_password(password_or_token) || password_or_token
                   end

    unless token?
      puts # i <3 vertical whitespace

      abort "Sorry, I can't auth you on GitHub.",
        "Please check your credentials and teams and give it another try."
    end
  end
end
