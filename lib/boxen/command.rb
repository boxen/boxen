require "boxen/command_status"

# Pulled in so the others don't have to
require "boxen/preflight"
require "boxen/postflight"
require "boxen/util/logging"

class Boxen::Command
  include Boxen::Util::Logging

  class UnknownCommandError < StandardError; end

  attr_reader :config

  def self.help
    raise "You should define this"
  end

  def self.detailed_help
    raise "You should definitely define this"
  end

  def self.preflight(*klasses)
    preflights.replace preflights | klasses.flatten
  end

  def self.preflights
    @preflights ||= []
  end

  def self.postflight(*klasses)
    postflights.replace postflights | klasses.flatten
  end

  def self.postflights
    @postflights ||= []
  end

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
    if @commands && name && @commands.has_key?(name.to_sym)
      @commands[name.to_sym].new(*args).invoke
    else
      raise UnknownCommandError,
        "could not find `#{name.inspect.to_s}` in the list of registered commands"
    end
  end

  def initialize(config, *args)
    @config = config
    @args   = args
  end

  def invoke
    if preflights?
      cmd_status = self.run

      postflights? if cmd_status.success?

      cmd_status
    end
  end

  def run
    raise "So your command #{self.class.name} hasn't defined a run method, so we dunno what to do. Sorry."
  end

  def preflights?
    if self.class.preflights.any?
      info "Performing preflight checks"
    end

    self.class.preflights.all? do |p|

      debug "Performing preflight check: #{p.name}"

      p = p.new(@config)
      status = p.ok?

      if status
        debug "Passed preflight check: #{p.class.name}"
      else
        p.run
      end

      status
    end
  end

  def postflights?
    if self.class.postflights.any?
      info "Performing postflight checks"
    end

    self.class.postflights.each do |p|
      p = p.new(@config)
      p.run unless p.ok?
    end
  end

  def debug?
    @config.debug?
  end
end

require "boxen/command/help"
require "boxen/command/version"
require "boxen/command/run"
require "boxen/command/project"
require "boxen/command/service"
