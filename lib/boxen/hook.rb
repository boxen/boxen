module Boxen
  class Hook
    attr_reader :config
    attr_reader :checkout
    attr_reader :puppet
    attr_reader :result

    @hooks = []

    def self.register(hook)
      @hooks << hook
    end

    def self.unregister(hook)
      @hooks.delete hook
    end

    def self.all
      @hooks || []
    end

    def initialize(config, checkout, puppet, result)
      @config   = config
      @checkout = checkout
      @puppet   = puppet
      @result   = result
    end

    def enabled?
      required_vars = Array(required_environment_variables)
      required_vars.any? && required_vars.all? do |var|
        ENV[var] && !ENV[var].empty?
      end
    end

    def perform?
      false
    end

    def run
      call if perform?
    end
  end
end

require "boxen/hook/github_issue"
require "boxen/hook/web"
