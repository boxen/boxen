require "boxen/checkout"
require "boxen/config"
require "boxen/hook"
require "boxen/flags"
require "boxen/puppeteer"
require "boxen/service"
require "boxen/util"
require "facter"

module Boxen
  class Runner
    attr_reader :config
    attr_reader :flags
    attr_reader :puppet
    attr_reader :checkout
    attr_reader :hooks

    def initialize(config, flags)
      @config   = config
      @flags    = flags
      @puppet   = Boxen::Puppeteer.new(@config)
      @checkout = Boxen::Checkout.new(@config)
      @hooks    = Boxen::Hook.all
    end

    def process
      # --env prints out the current BOXEN_ env vars.

      exec "env | grep ^BOXEN_ | sort" if flags.env?

      process_flags

      process_args

      # Actually run Puppet and return its result

      puppet.run
    end

    def run
      report(process)
    end

    def report(result)
      hooks.each { |hook| hook.new(config, checkout, puppet, result).run }

      result
    end

    def process_flags

      # --projects prints a list of available projects and exits.

      if flags.projects?
        puts "You can install any of these projects with `#{$0} <project-name>`:\n"

        config.projects.each do |project|
          puts "  #{project.name}"
        end

        exit
      end

      # --disable-services stops all services

      if flags.disable_services?
        Boxen::Service.list.each do |service|
          puts "Disabling #{service}..."
          service.disable
        end

        exit
      end

      # --enable-services starts all services

      if flags.enable_services?
        Boxen::Service.list.each do |service|
          puts "Enabling #{service}..."
          service.enable
        end

        exit
      end

      # --disable-service [name] stops a service

      if flags.disable_service?
        service = Boxen::Service.new(flags.disable_service)
        puts "Disabling #{service}..."
        service.disable

        exit
      end

      # --enable-service [name] starts a service

      if flags.enable_service?
        service = Boxen::Service.new(flags.enable_service)
        puts "Enabling #{service}..."
        service.enable

        exit
      end

      # --restart-service [name] starts a service

      if flags.restart_service?
        service = Boxen::Service.new(flags.restart_service)
        puts "Restarting #{service}..."
        service.disable
        service.enable

        exit
      end

      # --list-services lists all services

      if flags.list_services?
        Boxen::Service.list.each do |service|
          puts service
        end

        exit
      end

      # --restart-services restarts all services

      if flags.restart_services?
        Boxen::Service.list_enabled.each do |service|
          puts "Restarting #{service}..."
          service.disable
          service.enable
        end

        exit
      end

    end

    def process_args
      projects = flags.args.join(',')
      File.open("#{config.repodir}/.projects", "w+") do |f|
        f.truncate 0
        f.write projects
      end
    end
  end
end
