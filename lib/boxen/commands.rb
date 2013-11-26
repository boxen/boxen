module Boxen
  module Commands
    def self.all
      @commands
    end

    def self.register(name, klass)
      unless defined?(@commands)
        @commands = {}
      end

      @commands[name] = klass
    end

    def self.reset!
      @commands = {}
    end

    def self.invoke(name, *args)
      if @commands && @commands.has_key?(name)
        @commands[name].new(*args).invoke
      else
        raise "Could not find command #{name}!"
      end
    end
  end
end
