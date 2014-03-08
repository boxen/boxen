require "ansi"

module Boxen
  module Util
    module Logging

      # A fancier `abort` and `warn`. This will probably really annoy
      # someone at some point because it's overriding a Kernel method,
      # but it's limited to checks.

      alias :fail :abort

      def abort(message, *extras)
        extras << { :color => :red, :stream => $stderr }
        log "FAIL: #{message}", *extras
        exit 1
      end

      def warn(message, *extras)
        extras << { :color => :yellow, :stream => $stderr }
        log "--> #{message}", *extras
      end

      def info(message, *extras)
        extras << { :color => :cyan }
        log "--> #{message}", *extras
      end

      def debug(message, *extras)
        if debug?
          extras << { :color => :white }
          log "    DEBUG: #{message}", *extras
        end
      end

      def log(message, *extras)
        options = Hash === extras.last ? extras.pop : {}

        stream = options[:stream] || $stdout

        if color = options[:color]
          stream.puts ANSI.send(color) { message }
        else
          stream.puts message
        end

        unless extras.empty?
          extras.each { |line| stream.puts "    #{line}" }
        end
      end

      def debug?
        false
      end


    end
  end
end
