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
      # Clear the password. We're storing tokens now.
      set PASSWORD_SERVICE, ""
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

    def set(service, token)
      cmd = shellescape(HELPER, service, login, token).join ' '

      result = `#{cmd} 2>&1`.strip
      unless $?.success?
        raise Boxen::Error, "Can't save #{service} in the keychain.\nCommand: #{cmd}\nError: #{result}"
      end

      token
    end

    def shellescape(*args)
      args.map { |s| Shellwords.shellescape s }.join " "
    end
  end
end
