module Boxen
  module Util

    # Is Boxen active?

    def self.active?
      ENV.include? "BOXEN_HOME"
    end


    # Run `args` as a system command with sudo if necessary.

    def self.sudo *args
      system "sudo", "-p", "Password for sudo: ", *args
    end
  end
end
