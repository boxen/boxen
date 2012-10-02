require "boxen/preflight"

class Boxen::Preflight::Rbenv < Boxen::Preflight
  def run
    warn "You have an existing rbenv installed in ~/.rbenv.",
      "Boxen provides its own rbenv, so consider deleting yours."
  end

  def ok?
    !File.exist? "#{ENV['HOME']}/.rbenv"
  end
end
