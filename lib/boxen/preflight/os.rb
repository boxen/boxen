require "boxen/preflight"

class Boxen::Preflight::OS < Boxen::Preflight
  MIN_VERSION = '10.8'

  def ok?
    osx? && supported_release?
  end

  def run
    abort "You must be running at least the following OS X version: #{MIN_VERSION}."
  end

  private

  def osx?
    `uname -s`.chomp == "Darwin"
  end

  def supported_release?
    puts "#{current_release} >= #{MIN_VERSION}?"
    Gem::Version.new(current_release) >= Gem::Version.new(MIN_VERSION)
  end

  def current_release
    @current_release ||= `sw_vers -productVersion`
  end
end
