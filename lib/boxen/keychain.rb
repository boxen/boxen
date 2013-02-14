require "shellwords"

module Boxen
  class Keychain

    # The keychain proxy we use to provide isolation and a friendly
    # message in security prompts.

    HELPER = File.expand_path "../../../script/Boxen", __FILE__

    # The service name to use when loading/saving passwords.

    PASSWORD_SERVICE = "GitHub Password"

    # The service name to use when loading/saving API keys.

    TOKEN_SERVICE = "GitHub API Token"

    def initialize(login)
      @login = login
    end

    def password
      get PASSWORD_SERVICE
    end

    def password=(password)
      set PASSWORD_SERVICE, password
    end

    def token
      get TOKEN_SERVICE
    end

    def token=(token)
      set TOKEN_SERVICE, token
    end

    protected

    attr_reader :login

    def get(service)
      cmd = shellescape(HELPER, service, login)

      result = `#{cmd}`.strip
      $?.success? ? result : nil
    end

    def set(service, password)
      cmd = shellescape(HELPER, service, login, password)

      unless system *cmd
        raise Boxen::Error, "Can't save #{service} in the keychain."
      end

      password
    end

    def shellescape(*args)
      args.map { |s| Shellwords.shellescape s }.join " "
    end
  end
end
