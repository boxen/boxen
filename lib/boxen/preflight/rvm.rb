require "boxen/preflight"

class Boxen::Preflight::RVM < Boxen::Preflight
  def run
    abort "You have an rvm installed in ~/.rvm.",
      "Boxen uses rbenv to install ruby, so please `rvm implode`"
  end

  def ok?
    !File.exist? "#{ENV['HOME']}/.rvm"
  end
end
