require "boxen/postflight"
require "json"
require "net/http"

class Boxen::Postflight::WebHook < Boxen::Postflight
  def ok?
    !enabled?
  end

  attr_writer :checkout
  def checkout
    @checkout ||= Boxen::Checkout.new(config)
  end

  def run
    payload = {
      :login  => config.user,
      :sha    => checkout.sha,
      :status => command.success? ? 'success' : 'failure',
      :time   => "#{Time.now.utc.to_i}"
    }

    post_web_hook payload
  end

  def post_web_hook(payload)
    headers = { 'Content-Type' => 'application/json' }

    uri = URI.parse(URI.escape(ENV['BOXEN_WEB_HOOK_URL']))

    user, pass, host, port, path = \
      uri.user, uri.pass, uri.host, uri.port, uri.path

    request = Net::HTTP::Post.new(path, headers)

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

    response
  end

  def required_environment_variables
    ['BOXEN_WEB_HOOK_URL']
  end

  def enabled?
    required_vars = Array(required_environment_variables)
    required_vars.any? && required_vars.all? do |var|
      ENV[var] && !ENV[var].empty?
    end
  end
end
