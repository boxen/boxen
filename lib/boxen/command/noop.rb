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
    "noop a run of Boxen's managed puppet environment"
  end

  def noop
    true
  end

end

Boxen::Command.register :noop, Boxen::Command::Noop
