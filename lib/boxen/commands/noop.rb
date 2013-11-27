require "boxen/commands/run"

module Boxen
  module Commands
    class Noop < Run
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
  end
end

Boxen::Commands.register :noop, Boxen::Commands::Noop
