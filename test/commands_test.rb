require "boxen/commands"

module Boxen
  module Commands
    class Foo < Command
      def run
        puts "foo"
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
end
