require "boxen/preflight"

class Boxen::Preflight::OS < Boxen::Preflight
  SUPPORTED_RELEASES = %w(10.8 10.9 10.10)
  UPCOMING_RELEASES = %w(10.11)

  def ok?
    osx? && supported_release?
  end

  def run
    if upcoming_release?
      return warn "Boxen is working on support for OS X #{current_release}.",
        "Although Boxen has added initial recognition of #{current_release},",
        "it is not yet supported and you may encounter any number of problems."
    end

    abort "You must be running one of the following OS X versions: "\
    "#{SUPPORTED_RELEASES.join(' ')}."
  end

  private

  def osx?
    `uname -s`.chomp == "Darwin"
  end

  def included_release?(releases)
    releases.any? { |r| current_release.start_with? r }
  end

  def supported_release?
    included_release?(SUPPORTED_RELEASES)
  end

  def upcoming_release?
    included_release?(UPCOMING_RELEASES)
  end

  def current_release
    @current_release ||= `sw_vers -productVersion`.strip
  end
end
