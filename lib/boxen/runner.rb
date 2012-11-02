require "boxen/checkout"
require "boxen/config"
require "boxen/flags"
require "boxen/puppeteer"
require "boxen/reporter"
require "boxen/util"
require "facter"

module Boxen
  class Runner
    attr_reader :config
    attr_reader :flags
    attr_reader :puppet
    attr_reader :checkout
    attr_reader :reporter

    def initialize(config, flags)
      @config = config
      @flags  = flags
      @puppet   = Boxen::Puppeteer.new(@config)
      @checkout = Boxen::Checkout.new(@config)
      @reporter = Boxen::Reporter.new(@config, @checkout, @puppet)
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
      return result unless issues?

      if result.success?
        reporter.close_failures
      else
        warn "Sorry! Creating an issue on #{config.reponame}."
        reporter.record_failure
      end

      result
    end

    def process_flags

      # --projects prints a list of available projects and exits.

      if flags.projects?
        config.projects.each do |project|
          prefix = project.installed? ? "*" : " "
          puts "#{prefix} #{project.name}"
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

      # --list-services lists all services

      if flags.list_services?
        Boxen::Service.list.each do |service|
          puts service
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

    # Should the result of this run have any effect on GitHub issues?

    def issues?
      !config.stealth? && !config.pretend? && checkout.master?
    end
  end
end
