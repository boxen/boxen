require "boxen/util"

module Boxen
  class Service
    attr_reader :name

    def self.list
      files.collect do |service|
        new(human_name(service))
      end
    end

    def self.list_enabled
      prefix = /^dev\./
      enabled = capture_output("sudo /bin/launchctl list").split("\n").map { |l| l.split(/\s/) }.map(&:last)
      names = enabled.grep(prefix).map { |name| name.sub(prefix, "") }.compact
      names.map { |name| new(name) }
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

    def self.capture_output(command)
      `#{command}`
    end

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
