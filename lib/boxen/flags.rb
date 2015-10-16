require "optparse"
require "boxen/error"

module Boxen

  # Various flags and settings parsed from the command line. See
  # Setup::Configuration for more info.

  class Flags

    attr_reader :args
    attr_reader :homedir
    attr_reader :logfile
    attr_reader :login
    attr_reader :token
    attr_reader :srcdir
    attr_reader :user

    attr_reader :disable_service
    attr_reader :enable_service
    attr_reader :restart_service

    # Create a new instance, optionally providing CLI `args` to
    # parse immediately.

    def initialize(*args)
      @args             = []
      @debug            = false
      @env              = false
      @fde              = true
      @help             = false
      @pretend          = false
      @profile          = false
      @report           = false
      @graph            = false
      @projects         = false
      @stealth          = false
      @disable_service  = false
      @enable_service   = false
      @restart_service  = false
      @disable_services = false
      @enable_services  = false
      @restart_services = false
      @list_services    = false
      @color            = true

      @options = OptionParser.new do |o|
        o.banner = "Usage: #{File.basename $0} [options] [projects...]\n\n"

        o.on "--debug", "Be really verbose." do
          @debug = true
        end

        o.on "--pretend", "--noop", "Don't make changes." do
          @pretend = true
        end

        o.on "--report", "Enable puppet reports." do
          @report = true
        end

        o.on "--graph", "Enable generation of dependency graphs." do
          @graph = true
        end

        o.on "--env", "Show useful environment variables." do
          @env = true
        end

        o.on "--help", "-h", "-?", "Show help." do
          @help = true
        end

        o.on "--disable-service SERVICE", "Disable a Boxen service." do |service|
          @disable_service = service
        end

        o.on "--enable-service SERVICE", "Enable a Boxen service." do |service|
          @enable_service = service
        end

        o.on "--restart-service SERVICE", "Restart a Boxen service." do |service|
          @restart_service = service
        end

        o.on "--disable-services", "Disable all Boxen services." do
          @disable_services = true
        end

        o.on "--enable-services", "Enable all Boxen services." do
          @enable_services = true
        end

        o.on "--restart-services", "Restart all Boxen services." do
          @restart_services = true
        end

        o.on "--list-services", "List Boxen services." do
          @list_services = true
        end

        o.on "--homedir DIR", "Boxen's home directory." do |homedir|
          @homedir = homedir
        end

        o.on "--logfile DIR", "Boxen's log file." do |logfile|
          @logfile = logfile
        end

        o.on "--login LOGIN", "Your GitHub login." do |login|
          @login = login
        end

        o.on "--no-fde", "Don't require full disk encryption." do
          @fde = false
        end

        # --no-pull is used before options are parsed, but consumed here.

        o.on "--no-pull", "Don't try to update code before applying."

        o.on "--no-issue", "--stealth", "Don't open an issue on failure." do
          @stealth = true
        end

        o.on "--token TOKEN", "Your GitHub OAuth token." do |token|
          @token = token
        end

        o.on "--profile", "Profile the Puppet run." do
          @profile = true
        end

        o.on "--future-parser", "Enable the Puppet future parser" do
          @future_parser = true
        end

        o.on "--projects", "Show available projects." do
          @projects = true
        end

        o.on "--srcdir DIR", "The directory where repos live." do |srcdir|
          @srcdir = srcdir
        end

        o.on "--user USER", "Your local user." do |user|
          @user = user
        end

        o.on "--no-color", "Disable colors." do
          @color = false
        end
      end

      parse args.flatten.compact
    end

    # Apply these flags to `config`. Returns `config`.

    def apply(config)
      config.debug         = debug?
      config.fde           = fde?     if config.fde?
      config.homedir       = homedir  if homedir
      config.logfile       = logfile  if logfile
      config.login         = login    if login
      config.token         = token    if token
      config.pretend       = pretend?
      config.profile       = profile?
      config.future_parser = future_parser?
      config.report        = report?
      config.graph         = graph?
      config.srcdir        = srcdir   if srcdir
      config.stealth       = stealth?
      config.user          = user     if user
      config.color         = color?

      config
    end

    def debug?
      @debug
    end

    def env?
      @env
    end

    def fde?
      @fde
    end

    def help?
      @help
    end

    def disable_services?
      @disable_services
    end

    def enable_services?
      @enable_services
    end

    def disable_service?
      @disable_service
    end

    def enable_service?
      @enable_service
    end

    def restart_service?
      @restart_service
    end

    def restart_services?
      @restart_services
    end

    def list_services?
      @list_services
    end

    def run?
      !(
        list_services? ||
        restart_services? || restart_service? ||
        enable_services? || enable_service? ||
        disable_services? || disable_service? ||
        help?
      )
    end

    # Parse `args` as an array of CLI argument Strings. Raises
    # Boxen::Error if anything goes wrong. Returns `self`.

    def parse(*args)
      @args = @options.parse! args.flatten.compact.map(&:to_s)

      self

    rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
      raise Boxen::Error, "#{e.message}\n#@options"
    end

    def pretend?
      @pretend
    end

    def profile?
      @profile
    end

    def future_parser?
      @future_parser
    end

    def report?
      @report
    end

    def graph?
      @graph
    end

    def projects?
      @projects
    end

    def stealth?
      @stealth
    end

    def color?
      @color
    end

    def to_s
      @options.to_s
    end
  end
end
