require "boxen/preflight"

class Boxen::Preflight::RVM < Boxen::Preflight
  def run
    warn "You have an rvm installed in ~/.rvm.",
      "The Setup uses rbenv to install ruby, so consider `rvm implode`ing"
  end

  def ok?
    !File.exist? "#{ENV['HOME']}/.rvm"
  end
end
