require "boxen/command/run"

class Boxen::Command::Noop < Boxen::Command::Run
  preflight \
    Boxen::Preflight::Creds,
    Boxen::Preflight::Directories,
    Boxen::Preflight::EtcMyCnf,
    Boxen::Preflight::Homebrew,
    Boxen::Preflight::Identity,
    Boxen::Preflight::OS,
    Boxen::Preflight::Rbenv,
    Boxen::Preflight::RVM

  postflight \
    Boxen::Postflight::Active,
    Boxen::Postflight::Env

  def self.help
    "Noop a run of Boxen's managed puppet environment"
  end

  def self.detailed_help
    <<-EOS

    boxen noop [options]

        Noops Puppet via Boxen's environment.

        Some options you may find useful:

            --debug                 Be really, really verbose. Like incredibly verbose.
            --no-issue              Don't file an issue if the Boxen run fails.
            --no-color              Don't output any colored text to the tty.
            --report                Generate graphs and catalog data from Puppet.
            --profile               Display very high-level performance details from the Puppet run.

EOS
  end

  def noop
    true
  end

end

Boxen::Command.register :noop, Boxen::Command::Noop
