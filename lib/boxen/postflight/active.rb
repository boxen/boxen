require "boxen"
require "boxen/postflight"

# Checks to see if the basic environment is loaded.

class Boxen::Postflight::Active < Boxen::Postflight
  def ok?
    Boxen.active?
  end

  def run
    warn "You haven't loaded Boxen's environment yet!",
      "To permanently fix this, source #{config.envfile} at the end",
      "of your shell's startup file."
  end
end
