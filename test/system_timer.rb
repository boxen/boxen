# THIS IS SUCH HAX. Faraday helpfully reminds you to install
# `system_timer` if you're running Ruby 1.8, since Timeout can give
# unreliable results. We can't do this during first-time runs, since
# there's no C compiler available.
#
# To squash the message and stop confusing people, this shim just
# exposes Timeout as SystemTimer. I'm a bad person.

require "timeout"
SystemTimer = Timeout
