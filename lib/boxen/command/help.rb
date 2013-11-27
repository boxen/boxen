require "boxen/command"

class Boxen::Command::Help < Boxen::Command
  def self.help
    "Displays help, obviously"
  end

  def self.detailed_help
    <<-EOS

    boxen help [<command>]

        With no arguments, displays short help information for all commands.

        Given a command name as an argument, displays detailed help about that command.

EOS
  end

  def run
    if @args.any?
      puts Boxen::Command.all[@args.first.to_sym].detailed_help
    else
      Boxen::Command.all.each do |name, _|
        display_help_for_command name
      end
    end

    Boxen::CommandStatus.new(0)
  end

  def display_help_for_command(name)
    # only shows top-level commands, not subcommands
    unless name =~ /:/
      puts "    #{name.to_s.ljust(16)} #{Boxen::Command.all[name.to_sym].help}"
    end
  end
end

Boxen::Command.register :help, Boxen::Command::Help
