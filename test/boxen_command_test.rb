require "boxen/command"

class Failing < Boxen::Check
  def initialize(*args); end
  def ok?; false; end
  def run; warn "lol this fails in ur face"; end
end

class Boxen::Command::Foo < Boxen::Command
  def run
    puts "foo"
    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Barnette < Boxen::Command
  preflight Failing

  def run
    puts "bar"
    Boxen::CommandStatus.new(0)
  end
end

class Boxen::Command::Atmos < Boxen::Command
  postflight Failing

  def run
    puts "hello, cindarella"
    Boxen::CommandStatus.new(0)
  end
end

describe Boxen::Command do
  before do
    @config = Minitest::Mock.new
    def @config.debug?; false; end
  end

  it "registers commands and shoves them into a hash, and can invoke them" do
    Boxen::Command.register :foo, Boxen::Command::Foo

    stdout, _ = capture_io do
      Boxen::Command.invoke :foo, @config
    end

    assert_match "foo", stdout
  end

  it "fails with UnknownCommandError if the invoked command is not registered" do
    assert_raises Boxen::Command::UnknownCommandError do
      Boxen::Command.invoke :random_command
    end
  end

  it "fails with UnknownCommandError if the invoked command is nil" do
    assert_raises Boxen::Command::UnknownCommandError do
      Boxen::Command.invoke nil
    end
  end

  it "registers command aliases" do
    Boxen::Command.register :foo, Boxen::Command::Foo, :bar

    stdout, _ = capture_io do
      Boxen::Command.invoke :bar, @config
    end

    assert_match "foo", stdout
  end

  it "executes preflight hooks" do
    Boxen::Command.register :barnette, Boxen::Command::Barnette

    stdout, stderr = capture_io do
      Boxen::Command.invoke :barnette, @config
    end

    assert_match "lol this fails in ur face", stderr
    refute_match "bar", stdout
  end

  it "executes postflight hooks" do
    Boxen::Command.register :atmos, Boxen::Command::Atmos

    stdout, stderr = capture_io do
      Boxen::Command.invoke :atmos, @config
    end

    assert_match "lol this fails in ur face", stderr
    assert_match "hello, cindarella", stdout
  end
end
