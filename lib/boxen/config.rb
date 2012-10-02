require "fileutils"
require "json"
require "octokit"
require "boxen/project"

module Boxen

  # All configuration for Boxen, whether it's loaded from command-line
  # args, environment variables, config files, or the keychain.

  class Config

    # The service name to use when loading/saving config in the Keychain.

    KEYCHAIN_SERVICE = "Boxen"

    # Load config. Yields config if `block` is given.

    def self.load(&block)
      new do |config|
        home = ENV["BOXEN_HOME"] || "/opt/boxen"
        file = "#{home}/config/boxen/defaults.json"

        if File.file? file
          attrs = JSON.parse File.read file

          attrs.each do |key, value|
            if value && config.respond_to?(selector = "#{key}=")
              config.send selector, value
            end
          end
        end

        cmd = "security find-generic-password " +
          "-a #{config.user} -s '#{KEYCHAIN_SERVICE}' -w 2>/dev/null"

        password = `#{cmd}`.strip
        password = nil unless $?.success?

        config.password = password

        yield config if block_given?
      end
    end

    # Save `config`. Returns `config`. Note that this only saves data,
    # not flags. For example, `login` will be saved, but `stealth?`
    # won't.

    def self.save(config)
      attrs = {
        :email    => config.email,
        :homedir  => config.homedir,
        :login    => config.login,
        :name     => config.name,
        :srcdir   => config.srcdir,
        :user     => config.user
      }

      file = "#{config.homedir}/config/boxen/defaults.json"
      FileUtils.mkdir_p File.dirname file

      File.open file, "wb" do |f|
        f.write JSON.generate Hash[attrs.reject { |k, v| v.nil? }]
      end

      cmd = ["security", "add-generic-password",
             "-a", config.user, "-s", KEYCHAIN_SERVICE, "-U", "-w", config.password]

      unless system *cmd
        raise Boxen::Error, "Can't save config in the Keychain."
      end

      config
    end

    # Create a new instance. Yields `self` if `block` is given.

    def initialize(&block)
      @fde  = true
      @pull = true

      yield self if block_given?
    end

    # Create an API instance using the current user creds. A new
    # instance is created any time `login` or `password` change.

    def api
      @api ||= Octokit::Client.new :login => login, :password => password
    end

    # Spew a bunch of debug logging? Default is `false`.

    def debug?
      !!@debug
    end

    attr_writer :debug

    # A GitHub user's public email.

    attr_accessor :email

    # The shell script that loads Boxen's environment.

    def envfile
      "#{homedir}/env.sh"
    end

    # Is full disk encryption required? Default is `true`. Respects
    # the `BOXEN_NO_FDE` environment variable.

    def fde?
      !ENV["BOXEN_NO_FDE"] && @fde
    end

    attr_writer :fde

    # Boxen's home directory. Default is `"/opt/boxen"`. Respects the
    # `BOXEN_HOME` environment variable.

    def homedir
      @homedir || ENV["BOXEN_HOME"] || "/opt/boxen"
    end

    attr_writer :homedir

    # Boxen's log file. Default is `"/tmp/boxen.log"`. Respects the
    # `BOXEN_LOG_FILE` environment variable.

    def logfile
      @logfile || ENV["BOXEN_LOG_FILE"] || "/tmp/boxen.log"
    end

    attr_writer :logfile

    # A GitHub user login. Default is `nil`.

    attr_reader :login

    def login=(login)
      @api = nil
      @login = login
    end

    # Is Boxen running on the `master` branch?

    def master?
      `git symbolic-ref HEAD`.chomp == "refs/heads/master"
    end

    # A GitHub user's profile name.

    attr_accessor :name

    # A GitHub user password. Default is `nil`.

    attr_reader :password

    def password=(password)
      @api = nil
      @password = password
    end

    # Just go through the motions? Default is `false`.

    def pretend?
      !!@pretend
    end

    attr_writer :pretend

    # Run a profiler on Puppet? Default is `false`.

    def profile?
      !!@profile
    end

    attr_writer :profile

    # Dirty tree?
    def dirty?
      changes.empty?
    end

    def changes
      `git status --porcelain`.strip
    end

    # An Array of Boxen::Project entries, one for each project Boxen
    # knows how to manage.
    #
    # FIX: Revisit this once we restructure template projects. It's
    # broken for several reasons: It assumes paths that won't be
    # right, and it assumes projects live in the same repo as this
    # file.

    def projects
      root  = File.expand_path "../../..", __FILE__
      files = Dir["modules/github/manifests/projects/*.pp"]
      names = (files.map { |m| File.basename m, ".pp" } - %w(all)).sort

      names.map do |name|
        Boxen::Project.new "#{srcdir}/#{name}"
      end
    end

    # The directory where repos live. Default is
    # `"/Users/#{user}/src"`.

    def srcdir
      @srcdir || "/Users/#{user}/src"
    end

    attr_writer :srcdir

    # Don't auto-create issues on failure? Default is `false`.
    # Respects the `BOXEN_NO_ISSUE` environment variable.

    def stealth?
      !!ENV["BOXEN_NO_ISSUE"] || @stealth
    end

    attr_writer :stealth

    # A local user login. Default is the `USER` environment variable.

    def user
      @user || ENV["USER"]
    end

    attr_writer :user
  end
end
