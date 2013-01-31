require "boxen/hook/github_issue"
require "boxen/hook/web"

module Boxen
  module Hook
    def self.all
      [
        Boxen::Hook::GitHubIssue,
        Boxen::Hook::Web
      ]
    end

    class Base
      attr_reader :config
      attr_reader :checkout
      attr_reader :puppet
      attr_reader :result

      def initialize(config, checkout, puppet, result)
        @config   = config
        @checkout = checkout
        @puppet   = puppet
        @result   = result
      end

      def enabled?
        raise "needs implemented"
      end

      def run
        raise "needs implemented"
      end
    end
  end
end