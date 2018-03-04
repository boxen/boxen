require "boxen/preflight"

class Boxen::Preflight::OS < Boxen::Preflight
  SUPPORTED_RELEASES = %w(10.8 10.9 10.10 10.11 10.12 10.13)

  def ok?
    osx? && (skip_os_check? || supported_release?)
  end

  def run
    abort <<~HEREDOC
      You must be running one of the following Mac OS versions:

      #{pretty_list_output(SUPPORTED_RELEASES)}

      While not recommended, it is possible to ignore this warning and
      continue anyway. Just prefix your Boxen command with
      `SKIP_OS_CHECK=1`.
    HEREDOC
  end

  private

  def pretty_list_output(values)
    output = values.map { |value| "- #{value}" }
    output.join("\n")
  end

  def osx?
    `uname -s`.chomp == "Darwin"
  end

  def supported_release?
    SUPPORTED_RELEASES.any? do |r|
      current_release.start_with? r
    end
  end

  def current_release
    @current_release ||= `sw_vers -productVersion`
  end

  def skip_os_check?
    ENV['SKIP_OS_CHECK'] == '1'
  end
end
