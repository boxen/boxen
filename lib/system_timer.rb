# Faraday helpfully reminds you to install `system_timer` if you're
# running Ruby 1.8, since Timeout can give unreliable results. We
# can't do this during first-time runs, since there's no C compiler
# available.
#
# To squash the message and stop confusing people, this shim just
# exposes Timeout as SystemTimer. I'm a bad person.


if (!defined?(RUBY_ENGINE) || "ruby" == RUBY_ENGINE) && RUBY_VERSION < '1.9'
  require "timeout"
  SystemTimer = Timeout
end
