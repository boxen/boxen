require "boxen/preflight"

class Boxen::Preflight::Rbenv < Boxen::Preflight
  def run
    warn "You have an existing rbenv installed in ~/.rbenv.",
      "Boxen provides its own rbenv, so consider deleting yours."
  end

  def ok?
    rbenv_location = "#{ENV['HOME']}/.rbenv"
    !File.exist?(rbenv_location) ||
         (File.symlink?(rbenv_location) &&
          File.readlink(rbenv_location) == "/opt/rubies/")
  end
end
