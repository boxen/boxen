module Boxen
  module Util
    def self.active?
      ENV.include? 'BOXEN_HOME'
    end

    def self.sudo(*args)
      system 'sudo', '-p', 'Password for sudo: ', *args
    end
  end
end
