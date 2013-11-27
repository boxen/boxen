require "boxen/command"
require "boxen/service"

class Boxen::Command::Service < Boxen::Command
  def self.detailed_help
    <<-EOS

    boxen service

        Display all services Boxen knows about.

    boxen service:enable <service1> [<service2> ...]

        Enable and start a Boxen-managed service.

    boxen service:disable <service1> [<service2> ...]

        Disable and stop a Boxen-managed service.

    boxen service:restart <service1> [<service2> ...]

        Restart a Boxen-managed service.

    boxen service:enable_all

        Enable all Boxen-managed services.

    boxen service:disable_all

        Disable all Boxen-managed services.

    boxen service:restart_all

        Restart all Boxen-managed services.

EOS
  end

  def self.help
    "Show and manage Boxen services."
  end

  def run
    puts "Boxen manages the following services:\n\n"

    Boxen::Service.list.each do |service|
      puts "    #{service.name}"
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::Enable < Boxen::Command::Service
  def run
    return self.class.detailed_help if @args.empty?

    @args.each do |svc|
      puts "Enabling service: #{svc}"
      service = Boxen::Service.new(svc).enable
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::Disable < Boxen::Command::Service
  def run
    return self.class.detailed_help if @args.empty?

    @args.each do |svc|
      puts "Disabling service: #{svc}"
      service = Boxen::Service.new(svc).disable
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::Restart < Boxen::Command::Service
  def run
    return self.class.detailed_help if @args.empty?

    @args.each do |svc|
      puts "Restarting service: #{svc}"
      service = Boxen::Service.new(svc)
      service.disable
      service.enable
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::EnableAll < Boxen::Command::Service
  def run
    Boxen::Service.list.each do |service|
      puts "Enabling service: #{service.name}"
      service.enable
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::DisableAll < Boxen::Command::Service
  def run
    Boxen::Service.list.each do |service|
      puts "Disabling service: #{service.name}"
      service.disable
    end

    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Service::RestartAll < Boxen::Command::Service
  def run
    Boxen::Service.list.each do |service|
      puts "Restarting service: #{service.name}"
      service.disable
      service.enable
    end

    Boxen::CommandStatus.new(0)
  end
end

Boxen::Command.register :service, Boxen::Command::Service
Boxen::Command.register :"service:enable", Boxen::Command::Service::Enable
Boxen::Command.register :"service:disable", Boxen::Command::Service::Disable
Boxen::Command.register :"service:restart", Boxen::Command::Service::Restart
Boxen::Command.register :"service:enable_all", Boxen::Command::Service::EnableAll
Boxen::Command.register :"service:disable_all", Boxen::Command::Service::DisableAll
Boxen::Command.register :"service:restart_all", Boxen::Command::Service::RestartAll
