require "boxen/command"

class Boxen::Command::Run < Boxen::Command
  preflight \
    Boxen::Preflight::OS,
    Boxen::Preflight::Directories,
    Boxen::Preflight::EtcMyCnf,
    Boxen::Preflight::Homebrew,
    Boxen::Preflight::Rbenv,
    Boxen::Preflight::RVM,
    Boxen::Preflight::Offline,
    Boxen::Preflight::Creds,
    Boxen::Preflight::Identity,
    Boxen::Preflight::Update,
    Boxen::Preflight::Facts

  postflight \
    Boxen::Postflight::Active,
    Boxen::Postflight::Hooks,
    Boxen::Postflight::GithubIssue,
    Boxen::Postflight::Env

  def self.help
    "run Boxen's managed puppet environment"
  end

  def self.detailed_help
    <<-EOS

    boxen run [options]

        Runs Puppet via Boxen's environment.

        Some options you may find useful:

            --debug                 Be really, really verbose. Like incredibly verbose.
            --no-issue              Don't file an issue if the Boxen run fails.
            --no-color              Don't output any colored text to the tty.
            --report                Generate graphs and catalog data from Puppet.
            --profile               Display very high-level performance details from the Puppet run.
            --future-parser         Use Puppet's upcoming future parser
            --graph                 Enable puppet dependency graph output

    boxen run:noop [options]

        The same thing as run, but acts as a dry run where no changes are made.

EOS
  end

  def run
    info "Updating librarian-puppet modules"
    create_clean_working_environment
    run_librarian_puppet

    warn command.join(" ") if debug?

    info "Running puppet"
    Boxen::Util.sudo(*command)

    Boxen::CommandStatus.new($?.exitstatus, [0, 2])
  end

  def noop
    false
  end

  def report?
    @args.include? "--report"
  end

  def profile?
    @args.include? "--profile"
  end

  def future_parser?
    @args.include? "--future-parser"
  end

  def graph?
    @args.include? "--graph"
  end

  def debug?
    @args.include? "--debug"
  end

  def no_color?
    @args.include? "--no-color"
  end

  private
  def command
    [
     "#{config.repodir}/bin/puppet",
     "apply",
     puppet_flags,
     "#{config.repodir}/manifests/site.pp"
    ].flatten
  end

  def run_librarian_puppet
    if File.file? "#{config.repodir}/Puppetfile"
      librarian = "#{config.repodir}/bin/librarian-puppet"

      unless config.enterprise?
        ENV["GITHUB_API_TOKEN"] = config.token
      end

      librarian_command = [librarian, "install", "--path=#{config.repodir}/shared"]
      librarian_command << "--verbose" if debug?

      warn librarian_command.join(" ") if debug?
      unless system(*librarian_command)
        abort "Can't run Puppet, fetching dependencies with librarian failed."
      end
    end
  end

  def create_clean_working_environment
    FileUtils.mkdir_p config.puppetdir

    FileUtils.rm_f config.logfile

    FileUtils.rm_rf "#{config.puppetdir}/var/reports" if report?

    FileUtils.mkdir_p File.dirname config.logfile
    FileUtils.touch config.logfile
  end

  def hiera_config
    hiera_yaml = "#{config.repodir}/config/hiera.yaml"

    File.exists?(hiera_yaml) ? hiera_yaml : "/dev/null"
  end

  def puppet_flags
    _flags = []
    root  = File.expand_path "../../..", __FILE__

    _flags << ["--group",          "admin"]
    _flags << ["--confdir",        "#{config.puppetdir}/conf"]
    _flags << ["--vardir",         "#{config.puppetdir}/var"]
    _flags << ["--libdir",         "#{config.repodir}/lib"]#:#{root}/lib"]
    _flags << ["--libdir",         "#{root}/lib"]
    _flags << ["--manifestdir",    "#{config.repodir}/manifests"]
    _flags << ["--modulepath",     "#{config.repodir}/modules:#{config.repodir}/shared"]
    _flags << ["--hiera_config",   hiera_config]
    _flags << ["--logdest",        "#{config.repodir}/log/puppet.log"]
    _flags << ["--logdest",        "console"]
    _flags << ["--pluginfactdest", "#{config.homedir}/facts.d"]

    _flags << "--no-report" unless report?
    _flags << "--detailed-exitcodes"

    _flags << "--show_diff"

    if profile?
      _flags << "--evaltrace"
      _flags << "--summarize"
    end

    _flags << "--parser=future" if future_parser?
    _flags << "--graph" if graph?

    _flags << "--debug" if debug?
    _flags << "--noop"  if noop

    _flags << "--color=false" if no_color?

    _flags.flatten
  end
end

class Boxen::Command::Run::Noop < Boxen::Command::Run
  preflight \
    Boxen::Preflight::OS,
    Boxen::Preflight::Directories,
    Boxen::Preflight::EtcMyCnf,
    Boxen::Preflight::Homebrew,
    Boxen::Preflight::Rbenv,
    Boxen::Preflight::RVM,
    Boxen::Preflight::Offline,
    Boxen::Preflight::Creds,
    Boxen::Preflight::Identity,
    Boxen::Preflight::Update,
    Boxen::Preflight::Facts

  postflight \
    Boxen::Postflight::Active,
    Boxen::Postflight::Env

  def noop
    true
  end
end

Boxen::Command.register :run, Boxen::Command::Run
Boxen::Command.register :"run:noop", Boxen::Command::Run::Noop
