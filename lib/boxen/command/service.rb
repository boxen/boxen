require "boxen/command"
require "boxen/service"

class Boxen::Command::Service < Boxen::Command
  def self.detailed_help
    <<-EOS

    boxen service

        Display all services Boxen knows about.

    boxen service:enable <service1> [<service2> ...]

        Enable and start a Boxen-managed service. If none are given,
        enables and starts all Boxen-managed services.

    boxen service:disable <service1> [<service2> ...]

        Disable and stop a Boxen-managed service. If none are given,
        disables and stops all Boxen-managed services.

    boxen service:restart [<service1> <service2> ...]

        Restart a Boxen-managed service. If none are given, restarts all
        Boxen-managed services.

EOS
  end

  def self.help
    "Show and manage Boxen services."
  end

  def run
    @args = [] # we don't care about args here

    puts "Boxen manages the following services:\n\n"

    services.each do |service|
      puts "    #{service.name}"
    end

    Boxen::CommandStatus.new(0)
  end

  def services
    @services ||= if @args.any?
                    @args.map { |s| Boxen::Service.new(s) }
                  else
                    Boxen::Service.list
                  end
  end
end

require "boxen/command/service/enable"
require "boxen/command/service/disable"
require "boxen/command/service/restart"

Boxen::Command.register :service, Boxen::Command::Service
Boxen::Command.register :services, Boxen::Command::Service
