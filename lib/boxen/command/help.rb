require "boxen/command"

class Boxen::Command::Help < Boxen::Command
  def self.help
    "Displays help, obviously"
  end

  def run
    if @args.any?
      display_help_for_command @args.first.to_s
    else
      Boxen::Command.all.each do |name, _|
        display_help_for_command name
      end
    end

    Boxen::CommandStatus.new(0)
  end

  def display_help_for_command(name)
    puts "    #{name.to_s.ljust(16)} #{Boxen::Command.all[name.to_sym].help}"
  end
end

Boxen::Command.register :help, Boxen::Command::Help
