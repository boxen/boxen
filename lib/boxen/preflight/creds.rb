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
    api.user rescue nil
  end

  def run
    console = HighLine.new

    warn "Hey, I need your current GitHub credentials to continue."

    config.login = console.ask "GitHub login: " do |q|
      q.default = config.login || config.user
      q.validate = /\A[^@]+\Z/
    end
  
    puts "Instead of using a password, use a Personal Access Token. You can create one by going to https://github.com/settings/applications"
    config.token = console.ask "GitHub Persoanl Access Token: " do |q|
      q.echo = "*"
      q.validate = /\A[a-zA-Z0-9]{40}\z/
    end

    unless token?
      puts # i <3 vertical whitespace

      abort "Sorry, I can't auth you on GitHub.",
        "Please check your credentials and teams and give it another try."
    end
  end
end
