require "fileutils"
require "boxen/util"
require "shellwords"

module Boxen

  # Manages an invocation of puppet.

  class Puppeteer

    class Status < Struct.new(:code)
      # Puppet's detailed exit codes reserves 2 for a successful run with changes
      def success?
        [0,2].include?(code)
      end
    end

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def command
      manifestdir = "#{config.repodir}/manifests"
      puppet      = "#{config.repodir}/bin/puppet"

      [puppet, "apply", flags, manifestdir].flatten
    end

    def hiera_config
      if File.exist? "#{config.repodir}/config/hiera.yaml"
        "#{config.repodir}/config/hiera.yaml"
      else
        "/dev/null"
      end
    end

    def flags
      flags = []
      root  = File.expand_path "../../..", __FILE__

      flags << ["--group",       "admin"]
      flags << ["--confdir",     "#{config.puppetdir}/conf"]
      flags << ["--vardir",      "#{config.puppetdir}/var"]
      flags << ["--libdir",      "#{config.repodir}/lib"]#:#{root}/lib"]
      flags << ["--libdir",      "#{root}/lib"]
      flags << ["--modulepath",  "#{config.repodir}/modules:#{config.repodir}/shared"]

      # Don't ever complain about Hiera to me
      flags << ["--hiera_config", hiera_config]

      # Log to both the console and a file.

      flags << ["--logdest", config.logfile]
      flags << ["--logdest", "console"]

      # For some reason Puppet tries to set up a bunch of rrd stuff
      # (user, group) unless reports are completely disabled.

      flags << "--no-report" unless config.report?
      flags << "--detailed-exitcodes"

      flags << "--graph" if config.graph?

      flags << "--show_diff"

      if config.profile?
        flags << "--evaltrace"
        flags << "--summarize"
      end

      if config.future_parser?
        flags << "--parser=future"
      end

      flags << "--debug" if config.debug?
      flags << "--noop"  if config.pretend?

      flags << "--color=false" unless config.color?

      flags.flatten
    end

    def run
      FileUtils.mkdir_p config.puppetdir

      FileUtils.rm_f config.logfile

      FileUtils.rm_rf "#{config.puppetdir}/var/reports" if config.report?

      FileUtils.rm_rf "#{config.puppetdir}/var/state/graphs" if config.graph?

      FileUtils.mkdir_p File.dirname config.logfile
      FileUtils.touch config.logfile

      librarian("install --path=#{config.repodir}/shared")

      Boxen::Util.sudo(*command)

      Status.new($?.exitstatus)
    end

    def librarian(args)
      return unless puppetfile_present?

      ENV["GITHUB_API_TOKEN"] = config.token unless config.enterprise?

      librarian_command = "#{config.repodir}/bin/librarian-puppet"
      parsed_args = "#{librarian_command} #{args}".shellsplit
      parsed_args << "--verbose" if config.debug?

      warn parsed_args.join(" ") if config.debug?

      system(*parsed_args)

      abort_unless_successful_run
    end

    def puppetfile_present?
      File.file? "Puppetfile"
    end

    def abort_unless_successful_run
      msg = "Can't run Puppet, fetching dependencies with librarian failed."
      abort msg unless $?.exitstatus
    end

    def check_for_new_puppet_modules
      librarian("outdated")
    end
  end
end
