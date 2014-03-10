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
    self.class.preflights.each do |p|
      if p.name == preflight_name
        info "#{p.name}: #{p.new(@config).ok?.inspect}"
        return Boxen::CommandStatus.new(0)
      end
    end

    fail("Could not find a preflight named: #{preflight_name}")
  end

  def preflight_name
    "Boxen::Preflight::#{ARGV.first.capitalize}"
  end
end

Boxen::Command.register :preflight, Boxen::Command::Preflight
