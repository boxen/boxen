require "boxen/preflight"

class Boxen::Preflight::Identity < Boxen::Preflight
  def ok?
    return true if config.offline?
    
    !user || (config.email && config.name)
  end

  def run
    config.email = user.email
    config.name  = user.name
  end

  def user
    @user ||= config.api.user rescue nil
  end
end
