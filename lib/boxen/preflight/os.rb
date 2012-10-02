require "boxen/preflight"

class Boxen::Preflight::OS < Boxen::Preflight
  def ok?
    `sw_vers -productVersion`.start_with? "10.8"
  end

  def run
    abort "You must be running OS X 10.8 (Mountain Lion)."
  end
end
