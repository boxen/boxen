require "fileutils"
require "boxen"

module Boxen

  # Manages an invocation of puppet.

  class Puppeteer
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def command
      manifest = File.expand_path "../../../manifests/init.pp", __FILE__ # FIX
      puppet   = File.expand_path "../../../bin/puppet", __FILE__ # FIX

      [puppet, "apply", flags, manifest].flatten
    end

    def flags
      flags = []
      root  = File.expand_path "../../..", __FILE__

      flags << ["--confdir",     "/tmp/puppet/conf"]
      flags << ["--vardir",      "/tmp/puppet/var"]
      flags << ["--libdir",      "#{root}/lib"]
      flags << ["--manifestdir", "#{root}/manifests"]
      flags << ["--modulepath",  "#{root}/modules"]

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
      Boxen.sudo "/bin/mkdir", "-p", "/tmp/puppet"
      Boxen.sudo "/bin/rm", "-f", config.logfile

      warn command.join " " if config.debug?
      Boxen.sudo *command

      $?.exitstatus
    end
  end
end
