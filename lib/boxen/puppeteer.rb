require "fileutils"
require "boxen/util"

module Boxen

  # Manages an invocation of puppet.

  class Puppeteer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def command
      manifest = "#{config.repodir}/manifests/site.pp"
      puppet   = "#{config.repodir}/bin/puppet"

      [puppet, "apply", flags, manifest].flatten
    end

    def flags
      flags = []
      root  = File.expand_path "../../..", __FILE__

      flags << ["--confdir",     "#{config.puppetdir}/conf"]
      flags << ["--vardir",      "#{config.puppetdir}/var"]
      flags << ["--libdir",      "#{config.repodir}/lib"]
      flags << ["--manifestdir", "#{config.repodir}/manifests"]
      flags << ["--modulepath",  "#{config.repodir}/modules"]

      # Log to both the console and a file.

      flags << ["--logdest", config.logfile]
      flags << ["--logdest", "console"]

      # For some reason Puppet tries to set up a bunch of rrd stuff
      # (user, group) unless reports are completely disabled.

      flags << "--no-report"
      flags << "--detailed-exitcodes"

      if config.profile?
        flags << "--evaltrace"
        flags << "--summarize"
      end

      flags << "--debug" if config.debug?
      flags << "--noop"  if config.pretend?

      flags.flatten
    end

    def run
      FileUtils.mkdir_p config.puppetdir

      FileUtils.rm_f config.logfile

      FileUtils.mkdir_p File.dirname config.logfile
      FileUtils.touch config.logfile

      warn command.join " " if config.debug?
      Boxen::Util.sudo *command

      $?.exitstatus
    end
  end
end
