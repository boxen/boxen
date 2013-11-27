require "boxen/commands/command"

module Boxen
  module Commands
    class Help < Command

      def run
        if @args.any?
          display_help_for_command @args.first.to_s
        else
          Boxen::Commands.all.each do |name, _|
            unless name == :help
              display_help_for_command name
            end
          end
        end

        Boxen::CommandStatus.new(0)
      end

      def display_help_for_command(name)
        puts "    #{name.to_s.ljust(16)} #{Boxen::Commands.all[name.to_sym].help}"
      end
    end
  end
 end

Boxen::Commands.register :help, Boxen::Commands::Help
