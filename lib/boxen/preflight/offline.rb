require "socket"
require "timeout"

require "boxen/preflight"

class Boxen::Preflight::Offline < Boxen::Preflight
  def ok?
    config.offline = !google_reachable?

    info "Running boxen in offline mode as we couldn't reach google." if config.offline?

    true
  end

  def run
  end

  private

  def google_reachable?
    @online = begin
      timeout(1) do
        s = TCPSocket.new('google.com', 80)
        s.close
      end
      true
    rescue Errno::ECONNREFUSED
      true
    rescue Timeout::Error, StandardError
      false
    end
  end
end
