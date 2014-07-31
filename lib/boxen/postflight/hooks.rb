require "boxen/postflight"
require "boxen/hook"

# Prints deprecation notices for all pre-3.x style hooks

class Boxen::Postflight::Hooks < Boxen::Postflight
  def ok?
    !Boxen::Hook.all.any?
  end

  def run
    ::Boxen::Hook.all.each do |hook|
      warn "DEPRECATION WARNING: Boxen::Hook is deprecated (#{hook})"
    end
  end
end
