require "boxen/command"
require "boxen/version"

class Boxen::Command::Version < Boxen::Command
  def self.help
    "Displays the current version of Boxen"
  end

  def self.detailed_help
    <<-EOS

    boxen version

        Display the current version of the Boxen gem.

EOS
  end

  def run
    puts "Boxen #{version}"
    Boxen::CommandStatus.new(0)
  end

  def version
    Boxen::VERSION
  end
end

Boxen::Command.register :version, Boxen::Command::Version, :"-v", :"--version"
