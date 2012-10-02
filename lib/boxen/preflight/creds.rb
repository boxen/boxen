require "highline"
require "boxen/preflight"

# HACK: Unless this is `false`, HighLine has some really bizarre
# problems with empty/expended streams at bizarre intervals.

HighLine.track_eof = false

class Boxen::Preflight::Creds < Boxen::Preflight
  def ok?
    config.api.user rescue nil
  end

  def run
    console = HighLine.new

    warn "Hey, I need your current GitHub credentials to continue."

    config.login = console.ask "GitHub login: " do |q|
      q.default = config.login || config.user
    end

    config.password = console.ask "GitHub password: " do |q|
      q.echo = "*"
    end

    unless ok?
      puts # i <3 vertical whitespace

      abort "Sorry, I can't auth you on GitHub.",
        "Please check your credentials and teams and give it another try."
    end
  end
end
