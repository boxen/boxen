require "boxen/check"

module Boxen

  # The superclass for preflight checks.

  class Preflight < Boxen::Check

    # Load all available preflight checks.

    register File.expand_path("../preflight", __FILE__)
  end
end
