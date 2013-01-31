require "boxen/hook"
require "json"
require "net/http"

module Boxen
  module Hook
    class Web < Base
      def perform?
        enabled?
      end

      def enabled?
        ENV['BOXEN_WEB_HOOK_URL'] && !ENV['BOXEN_WEB_HOOK_URL'].empty?
      end

      def run
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
    end
  end
end
