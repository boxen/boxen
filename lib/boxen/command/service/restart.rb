require "boxen/command/service"

class Boxen::Command::Service::Restart < Boxen::Command::Service
  def run
    services.each do |service|
      puts "Restarting service: #{service.name}"
      service.disable
      service.enable
    end

    Boxen::CommandStatus.new(0)
  end

  def services
    @services ||= if @args.any?
                    @args.map { |s| Boxen::Service.new(s) }
                  else
                    Boxen::Service.list_enabled
                  end
  end
end

Boxen::Command.register :"service:restart", Boxen::Command::Service::Restart
Boxen::Command.register :"services:restart", Boxen::Command::Service::Restart
