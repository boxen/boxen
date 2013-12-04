require "boxen/command/service"

class Boxen::Command::Service::Enable < Boxen::Command::Service
  def run
    services.each do |service|
      puts "Enabling service: #{service.name}"
      service.enable
    end

    Boxen::CommandStatus.new(0)
  end
end

Boxen::Command.register :"service:enable", Boxen::Command::Service::Enable
Boxen::Command.register :"services:enable", Boxen::Command::Service::Enable
