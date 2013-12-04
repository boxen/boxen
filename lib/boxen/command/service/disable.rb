require "boxen/command/service"

class Boxen::Command::Service::Disable < Boxen::Command::Service
  def run
    services.each do |service|
      puts "Disabling service: #{service.name}"
      service.disable
    end

    Boxen::CommandStatus.new(0)
  end
end

Boxen::Command.register :"service:disable", Boxen::Command::Service::Disable
Boxen::Command.register :"services:disable", Boxen::Command::Service::Disable
