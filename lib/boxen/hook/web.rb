require "boxen/hook"
require "json"
require "net/http"

module Boxen
  class Hook
    class Web < Hook
      def perform?
        enabled?
      end

      private
      def call
        payload = {
          :login  => config.user,
          :sha    => checkout.sha,
          :status => result.success? ? 'success' : 'failure',
          :time   => "#{Time.now.utc.to_i}"
        }

        post_web_hook payload
      end

      def post_web_hook(payload)
        headers = { 'Content-Type' => 'application/json' }

        uri = URI.parse(URI.escape(ENV['BOXEN_WEB_HOOK_URL']))

        user, pass, host, port, path = \
          uri.user, uri.pass, uri.host, uri.port, uri.path

        request = Net::HTTP::Post.new(path, initheader = headers)

        if uri.scheme =~ /https/
          http.use_ssl = true
        end

        if user && pass
          request.basic_auth user, pass
        end

        request.body = payload.to_json

        response = Net::HTTP.new(host, port).start do |http|
          http.request(request)
        end
      end

      def required_environment_variables
        ['BOXEN_WEB_HOOK_URL']
      end
    end
  end
end

Boxen::Hook.register Boxen::Hook::Web
