module Boxen
  class Hook
    attr_reader :config
    attr_reader :checkout
    attr_reader :result

    def self.all
      @hooks
    end

    def self.register(klass)
      unless defined? @hooks
        @hooks = []
      end

      @hooks << klass
    end

    def self.run
      @hooks.each { |hook| hook.new(nil, nil, nil).run }
    end

    def initialize(config, checkout, result)
      @config   = config
      @checkout = checkout
      @result   = result
    end

    def enabled?
      required_vars = Array(required_environment_variables)
      required_vars.any? && required_vars.all? do |var|
        ENV[var] && !ENV[var].empty?
      end
    end

    def perform?
      enabled?
    end

    def run
      call if perform?
    end
  end
end

require "boxen/hook/github_issue"
require "boxen/hook/web"
