require "boxen/commands"

class Failing < Boxen::Check
  def initialize(*args); end
  def ok?; false; end
  def run; warn "lol this fails in ur face"; end
end

module Boxen
  module Commands
    class Foo < Command
      def run
        puts "foo"
        Boxen::CommandStatus.new(0)
      end
    end

    class Barnette < Command
      preflight Failing

      def run
        puts "bar"
        Boxen::CommandStatus.new(0)
      end
    end

    class Atmos < Command
      postflight Failing

      def run
        puts "hello, cindarella"
        Boxen::CommandStatus.new(0)
      end
    end
  end
end

describe Boxen::Commands do
  it "registers commands and shoves them into a hash, and can invoke them" do
    Boxen::Commands.register :foo, Boxen::Commands::Foo

    stdout, stderr = capture_io do
      Boxen::Commands.invoke :foo
    end

    assert_match "foo", stdout
  end

  it "executes preflight hooks" do
    Boxen::Commands.register :barnette, Boxen::Commands::Barnette

    stdout, stderr = capture_io do
      Boxen::Commands.invoke :barnette
    end

    assert_match "lol this fails in ur face", stderr
    refute_match "bar", stdout
  end

  it "executes postflight hooks" do
    Boxen::Commands.register :atmos, Boxen::Commands::Atmos

    stdout, stderr = capture_io do
      Boxen::Commands.invoke :atmos
    end

    assert_match "lol this fails in ur face", stderr
    assert_match "hello, cindarella", stdout
  end
end
