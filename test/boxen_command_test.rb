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
  it "registers commands and shoves them into a hash, and can invoke them" do
    Boxen::Command.register :foo, Boxen::Command::Foo

    stdout, stderr = capture_io do
      Boxen::Command.invoke :foo
    end

    assert_match "foo", stdout
  end

  it "executes preflight hooks" do
    Boxen::Command.register :barnette, Boxen::Command::Barnette

    stdout, stderr = capture_io do
      Boxen::Command.invoke :barnette
    end

    assert_match "lol this fails in ur face", stderr
    refute_match "bar", stdout
  end

  it "executes postflight hooks" do
    Boxen::Command.register :atmos, Boxen::Command::Atmos

    stdout, stderr = capture_io do
      Boxen::Command.invoke :atmos
    end

    assert_match "lol this fails in ur face", stderr
    assert_match "hello, cindarella", stdout
  end
end
