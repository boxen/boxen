module Boxen
  module Commands
    def self.register(name, klass)
      unless defined?(@commands)
        @commands = {}
      end

      @commands[name] = klass
    end

    def self.invoke(name, *args)
      if @commands && @commands.has_key?(name)
        @commands[name].new(*args).run
      else
        raise "Could not find command #{name}!"
      end
    end
  end
end
