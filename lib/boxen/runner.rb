require "boxen/checkout"
require "boxen/config"
require "boxen/hook"
require "boxen/flags"
require "boxen/service"
require "boxen/util"
require "facter"

module Boxen
  class Runner
    attr_reader :config
    attr_reader :flags
    attr_reader :checkout
    attr_reader :hooks

    def initialize(config, flags)
      @config   = config
      @flags    = flags
      @checkout = Boxen::Checkout.new(@config)
      @hooks    = Boxen::Hook.all
    end

    def process
      # --env prints out the current BOXEN_ env vars.

      exec "env | grep ^BOXEN_ | sort" if flags.env?

      process_flags

      process_args
    end

    def run
      report(process)
    end

    def report(result)
      hooks.each { |hook| hook.new(config, checkout, result).run }

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
