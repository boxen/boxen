require "boxen/commands/help"

class FooBar
  def self.help
    "help yourself"
  end
end

class BarBaz
  def self.help
    "no you"
  end
end

describe Boxen::Commands::Help do
  before do
    Boxen::Commands.reset!
    Boxen::Commands.register :foo_bar, FooBar
    Boxen::Commands.register :bar_baz, BarBaz
    Boxen::Commands.register :help, Boxen::Commands::Help
  end

  after do
    Boxen::Commands.reset!
  end

  it "can write help for all commands" do
    stdout, stderr = capture_io do
      Boxen::Commands.invoke(:help)
    end

    assert_match "    foo_bar          help yourself", stdout
    assert_match "    bar_baz          no you", stdout
  end

  it "can write help for a single command" do
    stdout, stderr = capture_io do
      Boxen::Commands.invoke(:help, "foo_bar")
    end

    assert_match "    foo_bar          help yourself", stdout
  end
end
