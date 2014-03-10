require "boxen/command"

class Boxen::Command::Preflight < Boxen::Command
  def self.help
    "Run a single preflight and return whether or not it's ok."
  end

  def self.detailed_help
    <<-EOS

    boxen preflight <check>

        Run preflight named <check> and return whether or not it's ok.

EOS
  end

  def run
    if defined?(preflight)
      info "#{preflight.name}: #{preflight.new(@config).ok?.inspect}"
      return Boxen::CommandStatus.new(0)
    else
      fail("Could not find a preflight named: #{preflight_name}")
    end
  rescue => e
    fail("Command failed: #{e.message} #{e.backtrace}")
  end

  def preflight
    Object.const_get(preflight_name)
  end

  def preflight_name
    "Boxen::Preflight::#{ARGV[1].capitalize}"
  end
end

Boxen::Command.register :preflight, Boxen::Command::Preflight
