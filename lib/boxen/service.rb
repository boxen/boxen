require 'boxen/util'

module Boxen
  class Service
    attr_reader :name

    def self.list
      files.collect do |service|
        new(human_name(service))
      end
    end

    def self.list_enabled
      service_list_names.map { |name| new(name) }
    end

    class << self
      private

      def service_list_names
        prefix = /^dev\./
        service_list.grep(prefix).map do |name|
          name.sub(prefix, '')
        end.compact
      end

      def service_list
        capture_output(service_list_cmd)
          .split("\n").map do |line|
            line.split(/\s/)
          end.map(&:last)
      end

      def capture_output(command)
        `#{command}`
      end

      def service_list_cmd
        'sudo /bin/launchctl list'
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
      '/Library/LaunchDaemons'
    end

    def self.files
      Dir["#{location}/dev.*.plist"]
    end

    def self.human_name(service)
      service.match(/dev\.(.+)\.plist$/)[1]
    end
  end
end
