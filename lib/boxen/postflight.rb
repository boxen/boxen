require "boxen/check"

module Boxen

  # The superclass for postflight checks.

  class Postflight < Boxen::Check

    # Load all available postflight checks.

    register File.expand_path("../postflight", __FILE__)
  end
end
