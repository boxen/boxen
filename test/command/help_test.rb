require "boxen/command/help"

class FooBar
  def self.detailed_help
    "okay fine I'll help you"
  end

  def self.help
    "help yourself"
  end
end

class BarBaz
  def self.help
    "no you"
  end
end

describe Boxen::Command::Help do
  before do
    Boxen::Command.reset!
    Boxen::Command.register :foo_bar, FooBar
    Boxen::Command.register :bar_baz, BarBaz
    Boxen::Command.register :help, Boxen::Command::Help
  end

  after do
    Boxen::Command.reset!
  end

  it "can write help for all commands" do
    stdout, _ = capture_io do
      Boxen::Command.invoke(:help)
    end

    assert_match "    foo_bar          help yourself", stdout
    assert_match "    bar_baz          no you", stdout
  end

  it "can write detailed help for a single command" do
    stdout, _ = capture_io do
      Boxen::Command.invoke(:help, "foo_bar")
    end

    assert_match "okay fine I'll help you", stdout
  end
end
