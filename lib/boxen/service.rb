require "boxen/util"

module Boxen
  class Service
    attr_reader :name

    def self.list
      files.collect do |service|
        new(human_name(service))
      end
    end

    def initialize(name)
      @name = name
    end

    def to_s
      name
    end

    def enable
      Boxen::Util.sudo('/bin/launchctl', 'load', '-w', location)
    end

    def disable
      Boxen::Util.sudo('/bin/launchctl', 'unload', '-w', location)
    end


    private

    def location
      "#{self.class.location}/dev.#{name}.plist"
    end

    def self.location
      "/Library/LaunchDaemons"
    end

    def self.files
      Dir["#{location}/dev.*.plist"]
    end

    def self.human_name(service)
      service.match(/dev\.(.+)\.plist$/)[1]
    end
  end
end
