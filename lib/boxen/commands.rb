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
      if @commands && @commands.has_key?(name.to_sym)
        @commands[name.to_sym].new(*args).invoke
      else
        raise "Could not find command #{name}!"
      end
    end
  end
end

Dir["#{File.expand_path('../commands', __FILE__)}/*"].each { |f| load f }
