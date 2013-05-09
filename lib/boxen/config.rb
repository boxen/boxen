require "boxen/keychain"
require "boxen/project"
require "fileutils"
require "json"
require "octokit"
require "shellwords"

module Boxen

  # All configuration for Boxen, whether it's loaded from command-line
  # args, environment variables, config files, or the keychain.

  class Config
    def self.load(&block)
      new do |config|
        file = "#{config.homedir}/config/boxen/defaults.json"

        if File.file? file
          attrs = JSON.parse File.read file

          attrs.each do |key, value|
            if !value.nil? && config.respond_to?(selector = "#{key}=")
              config.send selector, value
            end
          end
        end

        keychain        = Boxen::Keychain.new config.user
        config.password = keychain.password
        config.token    = keychain.token

        if config.enterprise?
          # configure to talk to GitHub Enterprise
          Octokit.configure do |c|
            c.api_endpoint = "#{config.ghurl}/api/v3"
            c.web_endpoint = config.ghurl
          end
        end

        yield config if block_given?
      end
    end

    # Save `config`. Returns `config`. Note that this only saves data,
    # not flags. For example, `login` will be saved, but `stealth?`
    # won't.

    def self.save(config)
      attrs = {
        :email     => config.email,
        :fde       => config.fde?,
        :homedir   => config.homedir,
        :login     => config.login,
        :name      => config.name,
        :puppetdir => config.puppetdir,
        :repodir   => config.repodir,
        :reponame  => config.reponame,
        :ghurl     => config.ghurl,
        :srcdir    => config.srcdir,
        :user      => config.user,
        :repourl   => config.repourl
      }

      file = "#{config.homedir}/config/boxen/defaults.json"
      FileUtils.mkdir_p File.dirname file

      File.open file, "wb" do |f|
        f.write JSON.generate Hash[attrs.reject { |k, v| v.nil? }]
      end

      keychain          = Boxen::Keychain.new config.user
      keychain.password = config.password
      keychain.token    = config.token

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

    # Boxen's log file. Default is `"#{repodir}/log/boxen.log"`.
    # Respects the `BOXEN_LOG_FILE` environment variable. The log is
    # overwritten on every run.

    def logfile
      @logfile || ENV["BOXEN_LOG_FILE"] || "#{repodir}/log/boxen.log"
    end

    attr_writer :logfile

    # A GitHub user login. Default is `nil`.

    attr_reader :login

    def login=(login)
      @api = nil
      @login = login
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

    # Enable puppet reports ? Default is `false`.

    def report?
      !!@report
    end

    attr_writer :report

    # An Array of Boxen::Project entries, one for each project Boxen
    # knows how to manage.
    #
    # FIX: Revisit this once we restructure template projects. It's
    # broken for several reasons: It assumes paths that won't be
    # right, and it assumes projects live in the same repo as this
    # file.

    def projects
      files = Dir["#{repodir}/modules/projects/manifests/*.pp"]
      names = files.map { |m| File.basename m, ".pp" }.sort

      names.map do |name|
        Boxen::Project.new "#{srcdir}/#{name}"
      end
    end

    # The directory where Puppet expects configuration (which we don't
    # use) and runtime information (which we generally don't care
    # about). Default is `/tmp/boxen/puppet`. Respects the
    # `BOXEN_PUPPET_DIR` environment variable.

    def puppetdir
      @puppetdir || ENV["BOXEN_PUPPET_DIR"] || "/tmp/boxen/puppet"
    end

    attr_writer :puppetdir

    # The directory of the custom Boxen repo for an org. Default is
    # `Dir.pwd`. Respects the `BOXEN_REPO_DIR` environment variable.

    def repodir
      @repodir || ENV["BOXEN_REPO_DIR"] || Dir.pwd
    end

    attr_writer :repodir

    # The repo on GitHub to use for error reports and automatic
    # updates, in `owner/repo` format. Default is the `origin` of a
    # Git repo in `repodir`, if it exists and points at GitHub.
    # Respects the `BOXEN_REPO_NAME` environment variable.

    def reponame
      override = @reponame || ENV["BOXEN_REPO_NAME"]
      return override unless override.nil?

      if File.directory? repodir
        %r|https?://(.*)| =~ ghurl
        domain = $1
        url = Dir.chdir(repodir) { `git config remote.origin.url`.strip }
        repo_exp = Regexp.new Regexp.escape(domain) + "[/:]([^/]+/[^/]+)"
        if $?.success? && repo_exp.match(url)
          @reponame = $1.sub /\.git$/, ""
        end
      end
    end

    attr_writer :reponame

    # GitHub location (public or GitHub Enterprise)

    def ghurl
      @ghurl || ENV["BOXEN_GITHUB_ENTERPRISE_URL"] || "https://github.com"
    end

    attr_writer :ghurl

    # Repository URL template (required for GitHub Enterprise)

    def repourl
      @repourl || ENV["BOXEN_REPO_URL_TEMPLATE"] || 'https://github.com/%s'
    end

    attr_writer :repourl

    # Does this Boxen use a GitHub Enterprise instance?

    def enterprise?
      ghurl != "https://github.com"
    end

    # The directory where repos live. Default is
    # `"/Users/#{user}/src"`.

    def srcdir
      @srcdir || ENV["BOXEN_SRC_DIR"] || "/Users/#{user}/src"
    end

    attr_writer :srcdir

    # Don't auto-create issues on failure? Default is `false`.
    # Respects the `BOXEN_NO_ISSUE` environment variable.

    def stealth?
      !!ENV["BOXEN_NO_ISSUE"] || @stealth
    end

    attr_writer :stealth

    # A GitHub OAuth token. Default is `nil`.

    attr_accessor :token

    # A local user login. Default is the `USER` environment variable.

    def user
      @user || ENV["USER"]
    end

    attr_writer :color

    def color?
      @color
    end

    attr_writer :user
  end
end
